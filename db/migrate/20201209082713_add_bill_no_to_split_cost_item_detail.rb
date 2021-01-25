class AddBillNoToSplitCostItemDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :split_cost_item_details, :bill_no, :string
  end
end
