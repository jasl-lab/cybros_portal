# frozen_string_literal: true

module SplitCost
  class SplitCostItem < ApplicationRecord
    validates :split_cost_item_no, :split_cost_item_name, :split_cost_item_category, presence: true
  end
end
