class AddItemNoNameCategoryToSplitCostItems < ActiveRecord::Migration[6.0]
  def change
    add_column :split_cost_items, :split_cost_item_no, :string
    add_column :split_cost_items, :split_cost_item_name, :string
    add_column :split_cost_items, :split_cost_item_category, :string
  end
end
