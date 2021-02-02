# frozen_string_literal: true

class Position < ApplicationRecord
  belongs_to :department, optional: true
  has_many :user_monthly_part_time_split_rates, class_name: 'SplitCost::UserMonthlyPartTimeSplitRate'
end
