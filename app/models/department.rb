class Department < ApplicationRecord
  has_many :department_users, dependent: :destroy
  has_many :users, through: :department_users
end
