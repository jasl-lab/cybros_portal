class MakePmonthMustFillForCostSplitAllocationBase < ActiveRecord::Migration[6.0]
  def change
    change_column_null(:cost_split_allocation_bases, :pmonth, false)
  end
end
