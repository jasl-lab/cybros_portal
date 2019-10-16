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
end
