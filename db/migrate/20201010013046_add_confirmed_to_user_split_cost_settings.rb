class AddConfirmedToUserSplitCostSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :user_split_cost_settings, :confirmed, :boolean, default: false, null: false
  end
end
