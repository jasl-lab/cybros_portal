# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable,
         :lockable, :invitable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  scope :active, -> { where(locked_at: nil) }

  has_many :department_users, dependent: :destroy
  has_many :departments, through: :department_users
  has_many :name_card_applies, dependent: :restrict_with_error
  has_many :pending_questions, class_name: "Company::PendingQuestion", dependent: :restrict_with_error
  has_many :owing_pending_questions, class_name: "Company::PendingQuestion", foreign_key: :owner_id
  has_one :knowledge_like, class_name: "Company::KnowledgeLike"

  def self.details_mapping
    @_username_details_mapping ||= all.joins(department_users: :department)
      .select(:email, :chinese_name, :desk_phone, "departments.name", "departments.company_name").reduce({}) do |h, u|
      user_name = u.email.split("@")[0]
      h[user_name] ||= "#{Bi::StaffCount.company_short_names.fetch(u.company_name, u.company_name)}-#{u.name}-#{u.chinese_name}-#{u.desk_phone}"
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

  def knowledge_maintainer?
    Company::Knowledge::KNOWLEDGE_MAINTAINER.include?(chinese_name) || admin?
  end

  def report_maintainer?
    %(崔立杰 亢梦婕 付焕鹏 曾嵘 过纯中 许瑞庭 王玥 冯巧容 陆文娟).include?(chinese_name) || admin?
  end

  def user_company_names
    @belongs_to_company_names ||= departments.collect(&:company_name)
  end

  def user_company_short_names
    @user_company_short_names ||= user_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
  end

  def user_company_short_name
    user_company_short_names.first
  end

  def in_tianhua_hq?
    user_company_names.include?("上海天华建筑设计有限公司")
  end
end
