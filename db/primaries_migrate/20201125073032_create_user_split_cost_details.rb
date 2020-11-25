class CreateUserSplitCostDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :user_split_cost_details do |t|
      t.string :v_wata_dept_code
      t.references :user, null: false
      t.date :month
      t.string :to_split_company_code
      t.decimal :group_cost
      t.decimal :shanghai_area_cost
      t.decimal :shanghai_hq_cost

      t.timestamps
    end
  end
end
