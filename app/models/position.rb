# frozen_string_literal: true

class Position < ApplicationRecord
  belongs_to :department, optional: true
  has_many :user_monthly_part_time_split_rates, class_name: 'SplitCost::UserMonthlyPartTimeSplitRate'
  belongs_to :baseline_position_access, foreign_key: :b_postcode, primary_key: :b_postcode, optional: true
end
