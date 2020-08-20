# frozen_string_literal: true

class DepartmentUser < ApplicationRecord
  belongs_to :department
  belongs_to :user
end
