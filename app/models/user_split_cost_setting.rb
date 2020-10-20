# frozen_string_literal: true

class UserSplitCostSetting < ApplicationRecord
  CALC_BASE_NAMES = %w[创意板块平均总人数 创意板块上海区域人数 上海天华人数 施工图人数 方案人数 建筑人数 结构人数 机电人数 外审事务所报价 创意板块及新业务 创意板块及新业务（上海区域） 武汉天华人数 创意板块及新业务（上海区域2020年1月年会人数） 创意板块及新业务（2020年12月31日人数） 室内、规划及景观 易术家 EID建筑及AICO室内 2019年参与设计大奖分摊人数]

  belongs_to :user

  validate :split_rate_reach_100

  def split_rate_reach_100
    return if group_rate.to_i + shanghai_area.to_i + shanghai_hq.to_i == 100

    errors.add(:group_rate, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.empty_text'))
    errors.add(:shanghai_area, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.empty_text'))
    errors.add(:shanghai_hq, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.rate_not_reach_to_100'))
  end
end
