# frozen_string_literal: true

module SplitCost
  class MonthlySalarySplitRule < ApplicationRecord
    belongs_to :user_job_type, class_name: 'SplitCost::UserJobType'
    belongs_to :user_salary_classification, class_name: 'SplitCost::UserSalaryClassification'
    belongs_to :user_cost_type, class_name: 'SplitCost::UserCostType'
  end
end
