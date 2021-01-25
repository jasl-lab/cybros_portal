class CreateSplitCostItemDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :split_cost_item_details do |t|
      t.references :split_cost_item, null: false, foreign_key: true
      t.date :month
      t.string :to_split_company_code
      t.decimal :group_cost
      t.decimal :shanghai_area_cost
      t.decimal :shanghai_hq_cost

      t.timestamps
    end
  end
end
