# frozen_string_literal: true

module SplitCost
  class UserSplitClassifySalary < ApplicationRecord
    belongs_to :user
    # belongs_to :user_job_type, class_name: 'SplitCost::UserJobType'
    # belongs_to :user_salary_classification, class_name: 'SplitCost::UserSalaryClassification'
  end
end
