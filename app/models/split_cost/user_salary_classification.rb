# frozen_string_literal: true

module SplitCost
  class UserSalaryClassification < ApplicationRecord
    has_many :user_split_classify_salaries
    has_many :user_monthly_part_time_split_rates
  end
end
