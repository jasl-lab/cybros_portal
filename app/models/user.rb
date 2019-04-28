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
end
