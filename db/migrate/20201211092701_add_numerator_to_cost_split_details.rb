class AddNumeratorToCostSplitDetails < ActiveRecord::Migration[6.0]
  def change
    add_column :split_cost_item_details, :group_cost_numerator, :decimal
    add_column :split_cost_item_details, :shanghai_area_cost_numerator, :decimal
    add_column :split_cost_item_details, :shanghai_hq_cost_numerator, :decimal
    add_column :user_split_cost_details, :group_cost_numerator, :decimal
    add_column :user_split_cost_details, :shanghai_area_cost_numerator, :decimal
    add_column :user_split_cost_details, :shanghai_hq_cost_numerator, :decimal
  end
end
