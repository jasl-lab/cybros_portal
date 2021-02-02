class CreateUserMonthlyPartTimeSplitRates < ActiveRecord::Migration[6.1]
  def change
    create_table :user_monthly_part_time_split_rates do |t|
      t.references :user, null: false, foreign_key: true
      t.date :month
      t.references :position, null: false, foreign_key: true
      t.boolean :main_position
      t.references :user_salary_classification, null: false, foreign_key: true, index: { name: 'idx_user_monthly_part_time_split_rates_on_classification_id' }
      t.integer :salary_classification_split_rate

      t.timestamps
    end
  end
end
