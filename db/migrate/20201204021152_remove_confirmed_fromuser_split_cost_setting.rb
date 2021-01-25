class RemoveConfirmedFromuserSplitCostSetting < ActiveRecord::Migration[6.0]
  def change
    remove_column :user_split_cost_settings, :confirmed, :boolean
  end
end
