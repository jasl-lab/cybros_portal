# frozen_string_literal: true

module SplitCost
  class UserSplitCostSetting < ApplicationRecord
    belongs_to :user
    has_many :user_split_cost_group_rate_companies
    has_many :user_split_cost_shanghai_area_rate_companies
    has_many :user_split_cost_shanghai_hq_rate_companies

    validate :split_rate_reach_100

    def split_rate_reach_100
      return if group_rate.to_i + shanghai_area.to_i + shanghai_hq.to_i == 100

      errors.add(:group_rate, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.empty_text'))
      errors.add(:shanghai_area, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.empty_text'))
      errors.add(:shanghai_hq, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.rate_not_reach_to_100'))
    end

    def user_split_cost_group_rate_companies_codes
      @_user_split_cost_group_rate_companies_codes ||= user_split_cost_group_rate_companies.pluck(:company_code)
    end

    def user_split_cost_group_rate_companies_codes=(values)
      select_values = values.reject(&:blank?)
      if new_record?
        (select_values - user_split_cost_group_rate_companies_codes).each do |new_company_code|
          user_split_cost_group_rate_companies.build(company_code: new_company_code)
        end
      else
        (user_split_cost_group_rate_companies_codes - select_values).each do |to_destroy_company_code|
          user_split_cost_group_rate_companies.find_by(company_code: to_destroy_company_code).destroy
        end
        (select_values - user_split_cost_group_rate_companies_codes).each do |to_add_company_code|
          user_split_cost_group_rate_companies.create(company_code: to_add_company_code)
        end
      end
    end

    def user_split_cost_shanghai_area_rate_companies_codes
      @_user_split_cost_shanghai_area_rate_companies_codes ||= user_split_cost_shanghai_area_rate_companies.pluck(:company_code)
    end

    def user_split_cost_shanghai_area_rate_companies_codes=(values)
      select_values = values.reject(&:blank?)
      if new_record?
        (select_values - user_split_cost_shanghai_area_rate_companies_codes).each do |new_company_code|
          user_split_cost_shanghai_area_rate_companies.build(company_code: new_company_code)
        end
      else
        (user_split_cost_shanghai_area_rate_companies_codes - select_values).each do |to_destroy_company_code|
          user_split_cost_shanghai_area_rate_companies.find_by(company_code: to_destroy_company_code).destroy
        end
        (select_values - user_split_cost_shanghai_area_rate_companies_codes).each do |to_add_company_code|
          user_split_cost_shanghai_area_rate_companies.create(company_code: to_add_company_code)
        end
      end
    end

    def user_split_cost_shanghai_hq_rate_companies_codes
      @_user_split_cost_shanghai_hq_rate_companies_codes ||= user_split_cost_shanghai_hq_rate_companies.pluck(:company_code)
    end

    def user_split_cost_shanghai_hq_rate_companies_codes=(values)
      select_values = values.reject(&:blank?)
      if new_record?
        (select_values - user_split_cost_shanghai_hq_rate_companies_codes).each do |new_company_code|
          user_split_cost_shanghai_hq_rate_companies.build(company_code: new_company_code)
        end
      else
        (user_split_cost_shanghai_hq_rate_companies_codes - select_values).each do |to_destroy_company_code|
          user_split_cost_shanghai_hq_rate_companies.find_by(company_code: to_destroy_company_code).destroy
        end
        (select_values - user_split_cost_shanghai_hq_rate_companies_codes).each do |to_add_company_code|
          user_split_cost_shanghai_hq_rate_companies.create(company_code: to_add_company_code)
        end
      end
    end
  end
end
