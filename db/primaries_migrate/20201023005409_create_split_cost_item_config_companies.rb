class CreateSplitCostItemConfigCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :split_cost_item_group_rate_companies do |t|
      t.references :split_cost_item, index: { name: "idx_split_cost_group_rate_on_companies_id" }
      t.string :company_code

      t.timestamps
    end
    create_table :split_cost_item_shanghai_area_rate_companies do |t|
      t.references :split_cost_item, index: { name: "idx_split_cost_shanghai_area_rate_on_companies_id" }
      t.string :company_code

      t.timestamps
    end
    create_table :split_cost_item_shanghai_hq_rate_companies do |t|
      t.references :split_cost_item, index: { name: "idx_split_cost_shanghai_hq_rate_on_companies_id" }
      t.string :company_code

      t.timestamps
    end
  end
end
