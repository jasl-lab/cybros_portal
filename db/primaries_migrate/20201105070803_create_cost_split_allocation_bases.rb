class CreateCostSplitAllocationBases < ActiveRecord::Migration[6.0]
  def change
    create_table :cost_split_allocation_bases do |t|
      t.string :base_name
      t.string :company_code
      t.integer :head_count
      t.date :start_date
      t.date :end_date
      t.integer :version

      t.timestamps
    end
  end
end
