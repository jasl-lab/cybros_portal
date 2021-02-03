# frozen_string_literal: true

module SplitCost
  class UserMonthlyPartTimeSplitRate < ApplicationRecord
    belongs_to :user
    belongs_to :position
    belongs_to :user_salary_classification

    def self.all_month_names
      SplitCost::UserMonthlyPartTimeSplitRate.order(month: :desc).select(:month).distinct.pluck(:month).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
