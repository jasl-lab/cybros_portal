# frozen_string_literal: true

module SplitCost
  class UserSplitClassifySalary < ApplicationRecord
    belongs_to :user
    belongs_to :user_job_types
    belongs_to :user_salary_classification
  end
end
