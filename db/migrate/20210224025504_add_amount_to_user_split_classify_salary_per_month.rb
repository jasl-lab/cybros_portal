class AddAmountToUserSplitClassifySalaryPerMonth < ActiveRecord::Migration[6.1]
  def change
    add_column :user_split_classify_salary_per_months, :amount, :decimal
  end
end
