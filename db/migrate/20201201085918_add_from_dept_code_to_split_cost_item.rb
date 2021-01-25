class AddFromDeptCodeToSplitCostItem < ActiveRecord::Migration[6.0]
  def change
    add_column :split_cost_items, :from_dept_code, :string
    add_column :split_cost_item_details, :from_dept_code, :string
  end
end
