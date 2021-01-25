class CreateUserSplitClassifySalaries < ActiveRecord::Migration[6.1]
  def change
    create_table :user_split_classify_salaries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :job_position
      t.string :job_type
      t.date :month
      t.decimal :amount
      t.string :amount_classification

      t.timestamps
    end
  end
end
