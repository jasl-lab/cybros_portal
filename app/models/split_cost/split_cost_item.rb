# frozen_string_literal: true

module SplitCost
  class SplitCostItem < ApplicationRecord
    CATEGORY = %w[固定资产 无形资产 业务性支出预算]
    has_many :split_cost_item_group_rate_companies
    has_many :split_cost_item_shanghai_area_rate_companies
    has_many :split_cost_item_shanghai_hq_rate_companies

    validates :split_cost_item_no, :split_cost_item_name, :split_cost_item_category, presence: true

    def split_cost_item_group_rate_companies_codes
      @_split_cost_item_group_rate_companies_codes ||= split_cost_item_group_rate_companies.pluck(:company_code)
    end

    def split_cost_item_group_rate_companies_codes=(values)
      select_values = values.reject(&:blank?)
      if new_record?
        (select_values - split_cost_item_group_rate_companies_codes).each do |new_company_code|
          split_cost_item_group_rate_companies.build(company_code: new_company_code)
        end
      else
        (split_cost_item_group_rate_companies_codes - select_values).each do |to_destroy_company_code|
          split_cost_item_group_rate_companies.find_by(company_code: to_destroy_company_code).destroy
        end
        (select_values - split_cost_item_group_rate_companies_codes).each do |to_add_company_code|
          split_cost_item_group_rate_companies.create(company_code: to_add_company_code)
        end
      end
    end

    def split_cost_item_shanghai_area_rate_companies_codes
      @_split_cost_item_shanghai_area_rate_companies_codes ||= split_cost_item_shanghai_area_rate_companies.pluck(:company_code)
    end

    def split_cost_item_shanghai_area_rate_companies_codes=(values)
      select_values = values.reject(&:blank?)
      if new_record?
        (select_values - split_cost_item_shanghai_area_rate_companies_codes).each do |new_company_code|
          split_cost_item_shanghai_area_rate_companies.build(company_code: new_company_code)
        end
      else
        (split_cost_item_shanghai_area_rate_companies_codes - select_values).each do |to_destroy_company_code|
          split_cost_item_shanghai_area_rate_companies.find_by(company_code: to_destroy_company_code).destroy
        end
        (select_values - split_cost_item_shanghai_area_rate_companies_codes).each do |to_add_company_code|
          split_cost_item_shanghai_area_rate_companies.create(company_code: to_add_company_code)
        end
      end
    end

    def split_cost_item_shanghai_hq_rate_companies_codes
      @_split_cost_item_shanghai_hq_rate_companies_codes ||= split_cost_item_shanghai_hq_rate_companies.pluck(:company_code)
    end

    def split_cost_item_shanghai_hq_rate_companies_codes=(values)
      select_values = values.reject(&:blank?)
      if new_record?
        (select_values - split_cost_item_shanghai_hq_rate_companies_codes).each do |new_company_code|
          split_cost_item_shanghai_hq_rate_companies.build(company_code: new_company_code)
        end
      else
        (split_cost_item_shanghai_hq_rate_companies_codes - select_values).each do |to_destroy_company_code|
          split_cost_item_shanghai_hq_rate_companies.find_by(company_code: to_destroy_company_code).destroy
        end
        (select_values - split_cost_item_shanghai_hq_rate_companies_codes).each do |to_add_company_code|
          split_cost_item_shanghai_hq_rate_companies.create(company_code: to_add_company_code)
        end
      end
    end
  end
end
