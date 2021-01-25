class AddSplitBaseToUserSplitCostSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :user_split_cost_settings, :group_rate_base, :string
    add_column :user_split_cost_settings, :shanghai_area_base, :string
    add_column :user_split_cost_settings, :shanghai_hq_base, :string
  end
end
