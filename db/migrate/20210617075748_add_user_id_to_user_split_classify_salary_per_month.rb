class AddUserIdToUserSplitClassifySalaryPerMonth < ActiveRecord::Migration[6.1]
  def change
    add_reference :user_split_classify_salary_per_months, :adjust_user, null: true, index: false
  end
end
