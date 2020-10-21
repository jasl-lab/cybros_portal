# frozen_string_literal: true

module SplitCost
  class UserSplitCostGroupRateCompany < ApplicationRecord
    belongs_to :user_split_cost_setting
  end
end
