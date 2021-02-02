# frozen_string_literal: true

module SplitCost
  class UserMonthlyPartTimeSplitRate < ApplicationRecord
    belongs_to :user
    belongs_to :position
    belongs_to :user_salary_classification
  end
end
