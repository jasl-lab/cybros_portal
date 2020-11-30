# frozen_string_literal: true

module SplitCost
  class SplitCostItemDetail < ApplicationRecord
    belongs_to :split_cost_item
  end
end
