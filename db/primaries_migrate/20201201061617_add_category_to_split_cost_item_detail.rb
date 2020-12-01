class AddCategoryToSplitCostItemDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :split_cost_item_details, :split_cost_item_category, :string
  end
end
