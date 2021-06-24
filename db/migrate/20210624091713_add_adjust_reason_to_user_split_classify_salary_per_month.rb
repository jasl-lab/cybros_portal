class AddAdjustReasonToUserSplitClassifySalaryPerMonth < ActiveRecord::Migration[6.1]
  def change
    add_column :user_split_classify_salary_per_months, :adjust_reason, :string
  end
end
