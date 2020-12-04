class SetVersionNullableForUserSplitCostSetting < ActiveRecord::Migration[6.0]
  def change
    change_column_null :user_split_cost_settings, :version, true
    change_column_null :user_split_cost_settings, :start_date, true
  end
end
