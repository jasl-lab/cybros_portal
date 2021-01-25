class RemoveConfirmedFromSplitCostItem < ActiveRecord::Migration[6.0]
  def change
    remove_column :split_cost_items, :confirmed, :boolean
  end
end
