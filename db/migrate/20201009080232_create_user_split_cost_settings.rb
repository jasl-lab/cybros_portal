class CreateUserSplitCostSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :user_split_cost_settings do |t|
      t.integer :group_rate, null: false
      t.integer :shanghai_area, null: false
      t.integer :shanghai_hq, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :version, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.string :org_code, null: false
      t.string :dept_code, null: false
      t.string :position_title, null: false

      t.timestamps
    end
  end
end
