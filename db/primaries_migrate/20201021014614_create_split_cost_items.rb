class CreateSplitCostItems < ActiveRecord::Migration[6.0]
  def change
    create_table :split_cost_items do |t|
      t.integer :group_rate
      t.integer :shanghai_area
      t.integer :shanghai_hq
      t.integer :version
      t.date :start_date
      t.date :end_date
      t.boolean :confirmed
      t.string :group_rate_base
      t.string :shanghai_area_base
      t.string :shanghai_hq_base

      t.timestamps
    end
  end
end
