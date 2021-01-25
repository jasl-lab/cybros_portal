class CreateUserSplitCostTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :user_job_types do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
    create_table :user_salary_classifications do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
    create_table :user_cost_types do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
    remove_column :user_split_classify_salaries, :job_type, :string
    add_reference :user_split_classify_salaries, :user_job_type
    remove_column :user_split_classify_salaries, :amount_classification, :string
    add_reference :user_split_classify_salaries, :user_salary_classification,  index: { name: "idx_user_split_classify_salaries_on_salary_classification_id" }
  end
end
