# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable, :lockable, :invitable,
         :recoverable, :rememberable, :confirmable, :trackable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  scope :active, -> { where(locked_at: nil) }

  has_many :department_users, dependent: :destroy
  has_many :departments, through: :department_users
  has_many :name_card_applies, dependent: :restrict_with_error
  has_many :pending_questions, class_name: "Company::PendingQuestion", dependent: :restrict_with_error

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
    email == 'chenzifan@thape.com.cn' || %(忻琳 聂玲玲 冯可 季建杰 柳怡帆).include?(chinese_name)
  end

  def report_maintainer?
    %(冯巧容 王玥 崔立杰 亢梦婕 付焕鹏 曾嵘 过纯中 许瑞庭 陈子凡).include?(chinese_name)
  end

  def user_company_names
    @belongs_to_company_names ||= departments.collect(&:company_name)
  end

  def in_tianhua_hq?
    user_company_names.include?('上海天华建筑设计有限公司')
  end
end
