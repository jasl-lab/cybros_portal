# frozen_string_literal: true

module SplitCost
  class UserSplitClassifySalaryPerMonth < ApplicationRecord
    belongs_to :user
    belongs_to :adjust_user, class_name: 'User', optional: true
    belongs_to :position
    belongs_to :user_job_type
    belongs_to :user_cost_type

    def self.all_month_names
      SplitCost::UserSplitClassifySalaryPerMonth.order(month: :desc).select(:month).distinct.pluck(:month).collect { |d| d.to_s(:month_and_year) }
    end
  end
end
