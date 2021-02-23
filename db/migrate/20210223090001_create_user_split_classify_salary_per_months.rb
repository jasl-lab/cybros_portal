class CreateUserSplitClassifySalaryPerMonths < ActiveRecord::Migration[6.1]
  def change
    create_table :user_split_classify_salary_per_months do |t|
      t.date :month, null: false
      t.references :user, null: false, foreign_key: true
      t.references :position, null: false, foreign_key: true
      t.references :user_job_type, null: false, foreign_key: true
      t.boolean :main_position, null: false, default: true
      t.references :user_cost_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
