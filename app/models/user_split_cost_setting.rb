# frozen_string_literal: true

class UserSplitCostSetting < ApplicationRecord
  CALC_BASE_NAMES = %w[创意板块平均总人数 创意板块上海区域人数 上海天华人数 施工图人数 方案人数 建筑人数 结构人数 机电人数 外审事务所报价 创意板块及新业务 创意板块及新业务（上海区域） 武汉天华人数 创意板块及新业务（上海区域2020年1月年会人数） 创意板块及新业务（2020年12月31日人数） 室内、规划及景观 易术家 EID建筑及AICO室内 2019年参与设计大奖分摊人数]

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
end
