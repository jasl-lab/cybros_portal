# frozen_string_literal: true

class User < ApplicationRecord
  include DeviseFailsafe
  include Devise::JWT::RevocationStrategies::Allowlist

  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable,
         :lockable, :invitable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  scope :active, -> { where(locked_at: nil) }

  has_many :role_users, dependent: :destroy
  has_many :roles, through: :role_users
  has_many :manual_operation_access_codes, dependent: :destroy
  has_many :manual_hr_access_codes, dependent: :destroy
  has_many :manual_cw_access_codes, dependent: :destroy
  has_many :part_time_split_access_codes, dependent: :destroy
  has_many :part_time_special_access_codes, dependent: :destroy

  has_many :department_users, dependent: :destroy
  has_many :departments, through: :department_users
  has_many :position_users, dependent: :destroy
  has_many :positions, through: :position_users

  has_many :name_card_applies, dependent: :restrict_with_error
  has_many :pending_questions, class_name: 'Company::PendingQuestion', dependent: :restrict_with_error
  has_many :owing_pending_questions, class_name: 'Company::PendingQuestion', foreign_key: :owner_id
  has_one :knowledge_like, class_name: 'Company::KnowledgeLike'
  has_many :cad_sessions, class_name: 'Cad::CadSession', dependent: :destroy
  has_many :cad_operations, class_name: 'Cad::CadOperation', dependent: :destroy
  has_many :report_view_histories

  # Setting at web page: cost_split_human_resources_path
  has_many :user_split_cost_settings, class_name: 'SplitCost::UserSplitCostSetting'
  # Generate at split_cost:generate_user_split_cost_details tasks
  has_many :user_split_cost_details, class_name: 'SplitCost::UserSplitCostDetail'
  # Import from NC via split_cost:nc_v_classify_salary_import
  has_many :user_split_classify_salaries, class_name: 'SplitCost::UserSplitClassifySalary'
  # Generate at split_cost:generate_user_monthly_part_time_splits
  # Edit at URL /cost_split/set_part_time_person_costs
  has_many :user_monthly_part_time_split_rates, class_name: 'SplitCost::UserMonthlyPartTimeSplitRate'

  has_many :market_entries, class_name: 'Market::MarketEntry'

  def self.details_mapping
    @_username_details_mapping ||= all.joins(department_users: :department)
      .select(:email, :chinese_name, :desk_phone, 'departments.name', 'departments.company_name').reduce({}) do |h, u|
      user_name = u.email.split('@')[0]
      h[user_name] ||= "#{Bi::OrgShortName.company_short_names.fetch(u.company_name, u.company_name)}-#{u.name}-#{u.chinese_name}-#{u.desk_phone}"
      h
    end
  end

  def admin?
    email.in? Settings.admin.emails
  end

  def self.find_for_jwt_authentication(sub)
    find_by(email: sub)
  end

  def jwt_subject
    email
  end

  def expired_jwts
    allowlisted_jwts.where('exp <= ?', Time.now)
  end

  def role_ids
    @_role_ids ||= roles.pluck(:id)
  end

  def role_ids=(values)
    select_values = values.reject(&:blank?).map(&:to_i)
    if new_record?
      (select_values - role_ids).each do |to_new_id|
        role_users.build(role_id: to_new_id)
      end
    else
      (role_ids - select_values).each do |to_destroy_id|
        role_users.find_by(role_id: to_destroy_id).destroy
      end
      (select_values - role_ids).each do |to_add_id|
        role_users.create(role_id: to_add_id)
      end
    end
  end

  def user_company_names
    @belongs_to_company_names ||= user_company_orgcodes.collect { |c| Bi::OrgShortName.company_long_names_by_orgcode.fetch(c, c) }
  end

  def user_company_short_names
    @user_company_short_names ||= user_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
  end

  def user_company_short_name
    user_company_short_names.first
  end

  def user_company_orgcodes
    @user_company_orgcodes ||= (operation_access_codes.collect { |c| c[1] } + departments.collect(&:company_code)).uniq
  end

  def user_cw_access_orgcodes
    @user_cw_access_orgcodes ||= manual_cw_access_codes.collect { |c| c.org_code }
  end

  def user_company_orgcode
    Bi::OrgShortName.org_code_by_short_name.fetch(user_company_short_name, user_company_short_name)
  end

  def user_department_codes
    @belongs_to_department_codes ||= departments.collect(&:dept_code)
  end

  def user_department_code
    user_department_codes.first
  end

  def user_department_names
    @belongs_to_department_names ||= departments.collect(&:name)
  end

  def user_department_name
    user_department_names.first
  end

  def in_tianhua_hq?
    user_company_names.include?('上海天华建筑设计有限公司')
  end

  ALL_OF_ALL = 1
  ALL_EXCEPT_OTHER_COMPANY_DETAILS = 2
  MY_COMPANY_ALL_DETAILS = 3
  MY_COMPANY_EXCEPT_OTHER_DEPTS = 4
  MY_DEPARTMENT = 5

  def can_access_org_codes
    return @_can_access_org_codes if @_can_access_org_codes.present?

    codes = operation_access_codes

    @_can_access_org_codes = codes.collect do |c|
      if c[0] == MY_DEPARTMENT
        nil
      else
        c[1]
      end
    end.reject(&:blank?)
    @_can_access_org_codes = @_can_access_org_codes.concat(user_company_orgcodes).uniq
  end

  def can_access_dept_codes
    return @_can_access_dept_codes if @_can_access_dept_codes.present?

    codes = operation_access_codes

    @_can_access_dept_codes = codes.collect do |c|
      c[2]
    end.reject(&:blank?).uniq
  end

  def position_titles
    operation_access_codes.collect { |c| c[3] }
  end

  def operation_access_codes
    return @_operation_access_codes if @_operation_access_codes.present?
    主职 = Hrdw::StfreinstateBi
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code)
    主职_access_codes = 主职.collect { |c| [User.calculate_operation_access_code(c.stname, c.zjname.to_i, c.orgcode, chinese_name), c.orgcode, c.deptcode_sum, c.stname, c.zjname.to_i, nil] }

    兼职 = Hrdw::StfreinstateVirtual
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code, pocname: ['内部兼职人员', '其他人员'])
      .select(:stname, :zjname, :orgcode, :deptcode_sum, :stname, :zjname).distinct
    兼职_access_codes = 兼职.collect { |c| [User.calculate_operation_access_code(c.stname, c.zjname.to_i, c.orgcode, chinese_name), c.orgcode, c.deptcode_sum, c.stname, c.zjname.to_i, nil] }

    手工_access_codes = manual_operation_access_codes.collect { |m| [m.code, m.org_code, m.dept_code, m.title, m.job_level, m.id] }
    @_operation_access_codes = 主职_access_codes + 兼职_access_codes + 手工_access_codes
  end

  def hr_access_codes
    return @_hr_access_codes if @_hr_access_codes.present?
    主职 = Hrdw::StfreinstateBi
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code)
    主职_access_codes = 主职.collect { |c| [c.orgcode, c.deptcode_sum, c.stname, c.zjname.to_i, c.name] }

    兼职 = Hrdw::StfreinstateVirtual
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code, pocname: ['内部兼职人员', '其他人员'])
      .select(:orgcode, :deptcode_sum, :stname, :zjname, :name).distinct
    兼职_access_codes = 兼职.collect { |c| [c.orgcode, c.deptcode_sum, c.stname, c.zjname.to_i, c.name] }

    @_hr_access_codes = 主职_access_codes + 兼职_access_codes
  end

  def cw_access_codes
    return @_cw_access_codes if @_cw_access_codes.present?
    主职 = Hrdw::StfreinstateBi
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code)
    主职_access_codes = 主职.collect { |c| [c.orgcode, c.deptcode_sum, c.stname, c.zjname.to_i, c.name] }

    兼职 = Hrdw::StfreinstateVirtual
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code, pocname: ['内部兼职人员', '其他人员'])
      .select(:orgcode, :deptcode_sum, :stname, :zjname, :name).distinct
    兼职_access_codes = 兼职.collect { |c| [c.orgcode, c.deptcode_sum, c.stname, c.zjname.to_i, c.name] }

    @_cw_access_codes = 主职_access_codes + 兼职_access_codes
  end

  def current_user_split_cost_setting
    user_split_cost_settings.where.not(start_date: nil).order(version: :desc).find_by(end_date: nil) ||
      user_split_cost_settings.where(start_date: nil).order(version: :desc).find_by(end_date: nil)
  end

  def wecom_id_with_fallback
    wecom_id.present? ? wecom_id : email.split('@')[0]
  end

  private

    def self.calculate_operation_access_code(基准岗位, job_level, org_code, chinese_name)
      return MY_DEPARTMENT if 基准岗位.nil?

      access_code = if %w[夏馥莹 张骏].include?(chinese_name)
        MY_DEPARTMENT # special rule
      elsif 基准岗位.include?('董事长') && job_level >= 18
        ALL_EXCEPT_OTHER_COMPANY_DETAILS
      elsif 基准岗位.include?('副总经理') && job_level >= 16
        MY_COMPANY_ALL_DETAILS
      elsif 基准岗位.include?('总经理助理') && job_level >= 15
        MY_COMPANY_ALL_DETAILS
      elsif (基准岗位.include?('市场总监') || 基准岗位.include?('市场运营总监') || 基准岗位 == '财务部经理') && job_level >= 13
        MY_COMPANY_ALL_DETAILS
      elsif 基准岗位.include?('经营核算主管') && job_level >= 8
        MY_COMPANY_ALL_DETAILS
      elsif 基准岗位.include?('总经理') && job_level >= 17
        ALL_EXCEPT_OTHER_COMPANY_DETAILS
      elsif (基准岗位.include?('商务经理') || 基准岗位.include?('商务助理')) && job_level >= 11
        MY_COMPANY_EXCEPT_OTHER_DEPTS
      elsif 基准岗位.include?('所长助理') && job_level >= 12
        MY_COMPANY_EXCEPT_OTHER_DEPTS
      elsif 基准岗位.include?('管理副所长') && job_level >= 13
        MY_COMPANY_EXCEPT_OTHER_DEPTS
      elsif 基准岗位.include?('所长') && job_level >= 14
        MY_COMPANY_EXCEPT_OTHER_DEPTS
      else
        MY_DEPARTMENT
      end
      if org_code == '000109' && access_code == MY_COMPANY_EXCEPT_OTHER_DEPTS
        MY_DEPARTMENT
      else
        access_code
      end
    end
end
