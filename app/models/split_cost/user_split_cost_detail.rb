# frozen_string_literal: true

module SplitCost
  class UserSplitCostDetail < ApplicationRecord
    belongs_to :user

    def self.all_month_names
      order(month: :desc).distinct.pluck(:month).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
