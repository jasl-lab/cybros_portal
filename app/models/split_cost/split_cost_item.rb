# frozen_string_literal: true

module SplitCost
  class SplitCostItem < ApplicationRecord
    CATEGORY = %w[固定资产 无形资产 业务性支出预算]
    has_many :split_cost_item_group_rate_companies
    has_many :split_cost_item_shanghai_area_rate_companies
    has_many :split_cost_item_shanghai_hq_rate_companies

    validates :split_cost_item_no, :split_cost_item_name, :split_cost_item_category, presence: true
  end
end
