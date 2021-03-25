# frozen_string_literal: true

module SplitCost
  class UserMonthlyPartTimeSpecialJobType < ApplicationRecord
    belongs_to :user
    belongs_to :position_user
    belongs_to :user_job_type

    def self.all_month_names
      current_date = Date.today
      dates = [current_date]
      while current_date > Date.new(2021, 2, 1) do
        current_date = current_date.prev_month
        dates << current_date
      end
      dates.collect { |d| d.to_s(:month_and_year) }
    end
  end
end
