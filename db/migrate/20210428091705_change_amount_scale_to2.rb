class ChangeAmountScaleTo2 < ActiveRecord::Migration[6.1]
  def change
    change_column :user_split_classify_salary_per_months, :amount, :decimal, precision: 10, scale: 2
  end
end
