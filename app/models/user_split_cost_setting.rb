class UserSplitCostSetting < ApplicationRecord
  belongs_to :user

  validate :split_rate_reach_100

  def split_rate_reach_100
    return if group_rate.to_i + shanghai_area.to_i + shanghai_hq.to_i == 100

    errors.add(:group_rate, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.empty_text'))
    errors.add(:shanghai_area, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.empty_text'))
    errors.add(:shanghai_hq, I18n.t('cost_split.human_resources.user_split_cost_setting_form.errors.rate_not_reach_to_100'))
  end
end
