# frozen_string_literal: true

module SplitCost
  class MonthlySalarySplitRule < ApplicationRecord
    belongs_to :user_job_type, class_name: 'SplitCost::UserJobType'
    belongs_to :user_salary_classification, class_name: 'SplitCost::UserSalaryClassification'
    belongs_to :user_cost_type, class_name: 'SplitCost::UserCostType'

    def self.all_month_names
      SplitCost::MonthlySalarySplitRule.order(month: :desc).pluck(:month).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
