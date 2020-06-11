# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable,
         :lockable, :invitable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  scope :active, -> { where(locked_at: nil) }

  has_many :role_users, dependent: :destroy
  has_many :roles, through: :role_users
  has_many :department_users, dependent: :destroy
  has_many :departments, through: :department_users
  has_many :copy_of_business_license_applies, class_name: 'Personal::CopyOfBusinessLicenseApply', dependent: :restrict_with_error
  has_many :official_stamp_usage_applies, class_name: 'Company::OfficialStampUsageApply', dependent: :restrict_with_error
  has_many :proof_of_employment_applies, class_name: 'Personal::ProofOfEmploymentApply', dependent: :restrict_with_error
  has_many :proof_of_income_applies, class_name: 'Personal::ProofOfIncomeApply', dependent: :restrict_with_error
  has_many :public_rental_housing_applies, class_name: 'Personal::PublicRentalHousingApply', dependent: :restrict_with_error
  has_many :name_card_applies, dependent: :restrict_with_error
  has_many :pending_questions, class_name: "Company::PendingQuestion", dependent: :restrict_with_error
  has_many :owing_pending_questions, class_name: "Company::PendingQuestion", foreign_key: :owner_id
  has_one :knowledge_like, class_name: "Company::KnowledgeLike"
  has_many :cad_sessions, class_name: "Cad::CadSession", dependent: :destroy
  has_many :cad_operations, class_name: "Cad::CadOperation", dependent: :destroy

  def self.details_mapping
    @_username_details_mapping ||= all.joins(department_users: :department)
      .select(:email, :chinese_name, :desk_phone, "departments.name", "departments.company_name").reduce({}) do |h, u|
      user_name = u.email.split("@")[0]
      h[user_name] ||= "#{Bi::OrgShortName.company_short_names.fetch(u.company_name, u.company_name)}-#{u.name}-#{u.chinese_name}-#{u.desk_phone}"
      h
    end
  end

  def admin?
    email.in? Settings.admin.emails
  end

  include DeviseFailsafe
  include Devise::JWT::RevocationStrategies::Allowlist

  def self.find_for_jwt_authentication(sub)
    find_by(email: sub)
  end

  def jwt_subject
    email
  end

  def expired_jwts
    allowlisted_jwts.where("exp <= ?", Time.now)
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
    @belongs_to_company_names ||= departments.collect(&:company_name)
  end

  def user_company_short_names
    @user_company_short_names ||= user_company_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
  end

  def user_company_short_name
    user_company_short_names.first
  end

  def user_company_orgcode
    Bi::OrgShortName.org_code_by_short_name.fetch(user_company_short_name, user_company_short_name)
  end

  def user_department_names
    @belongs_to_department_names ||= departments.collect(&:name)
  end

  def user_department_name
    user_department_names.first
  end

  def in_tianhua_hq?
    user_company_names.include?("上海天华建筑设计有限公司")
  end

  ALL_EXCEPT_OTHER_COMPANY_DETAILS = 2
  MY_COMPANY_ALL_DETAILS = 3
  MY_COMPANY_EXCEPT_OTHER_DEPTS = 4
  MY_DEPARTMENT = 5

  def can_access_org_codes
    return @_can_access_org_codes if @_can_access_org_codes.present?

    codes = my_access_codes

    return 'ALL' if codes.any? { |c| c[0] == ALL_EXCEPT_OTHER_COMPANY_DETAILS }

    @_can_access_org_codes = codes.collect do |c|
      if c[0] == MY_DEPARTMENT
        nil
      else
        c[1]
      end
    end.reject(&:blank?).uniq
  end

  def my_access_codes
    主职 = Bi::HrdwStfreinstateBi
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code)
    主职_access_codes = 主职.collect { |c| [User.calculate_access_code(c.stname, c.zjname.to_i, c.orgcode), c.orgcode, c.deptcode_sum, c.stname, c.zjname] }

    兼职 = Bi::HrdwStfreinstateVirtual
      .where(endflag: 'N', lastflag: 'Y', clerkcode: clerk_code, pocname: '内部兼职人员')
    兼职_access_codes = 兼职.collect { |c| [User.calculate_access_code(c.stname, c.zjname.to_i, c.orgcode), c.orgcode, c.deptcode_sum, c.stname, c.zjname] }
    主职_access_codes + 兼职_access_codes
  end

  private

  def self.calculate_access_code(stname, zjname, org_code)
    access_code = if stname.include?('董事长') && zjname >= 18
       ALL_EXCEPT_OTHER_COMPANY_DETAILS
    elsif stname.include?('副总经理') && zjname >= 16
      MY_COMPANY_ALL_DETAILS
    elsif stname.include?('总经理助理') && zjname >= 15
      MY_COMPANY_ALL_DETAILS
    elsif (stname.include?('市场总监') || stname.include?('市场运营总监')) && zjname >= 13
      MY_COMPANY_ALL_DETAILS
    elsif stname.include?('总经理') && zjname >= 17
      ALL_EXCEPT_OTHER_COMPANY_DETAILS
    elsif (stname.include?('商务经理') || stname.include?('商务助理')) && zjname >= 11
      MY_COMPANY_EXCEPT_OTHER_DEPTS
    elsif stname.include?('所长助理') && zjname >= 12
      MY_COMPANY_EXCEPT_OTHER_DEPTS
    elsif stname.include?('管理副所长') && zjname >= 13
      MY_COMPANY_EXCEPT_OTHER_DEPTS
    elsif stname.include?('所长') && zjname >= 14
      MY_COMPANY_EXCEPT_OTHER_DEPTS
    else
      MY_DEPARTMENT
    end
    if org_code == '000109' && access_code == MY_COMPANY_EXCEPT_OTHER_DEPTS
      return MY_DEPARTMENT
    else
      return access_code
    end
  end
end
