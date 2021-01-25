class CreateUserSplitCostGroupRateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :user_split_cost_group_rate_companies do |t|
      t.references :user_split_cost_setting, index: { name: "idx_split_cost_group_rate_on_setting_id" }
      t.string :company_code

      t.timestamps
    end
    create_table :user_split_cost_shanghai_area_rate_companies do |t|
      t.references :user_split_cost_setting, index: { name: "idx_split_cost_shanghai_area_rate_on_setting_id" }
      t.string :company_code

      t.timestamps
    end
    create_table :user_split_cost_shanghai_hq_rate_companies do |t|
      t.references :user_split_cost_setting, index: { name: "idx_split_cost_shanghai_hq_rate_on_setting_id" }
      t.string :company_code

      t.timestamps
    end
  end
end
