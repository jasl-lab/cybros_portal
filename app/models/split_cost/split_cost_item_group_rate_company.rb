# frozen_string_literal: true

module SplitCost
  class SplitCostItemGroupRateCompany < ApplicationRecord
    belongs_to :split_cost_item
  end
end
