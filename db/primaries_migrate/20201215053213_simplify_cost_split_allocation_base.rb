class SimplifyCostSplitAllocationBase < ActiveRecord::Migration[6.0]
  def change
    remove_column :cost_split_allocation_bases, :start_date, :date
    remove_column :cost_split_allocation_bases, :end_date, :date
    remove_column :cost_split_allocation_bases, :version, :integer
    add_column :cost_split_allocation_bases, :pmonth, :string
  end
end
