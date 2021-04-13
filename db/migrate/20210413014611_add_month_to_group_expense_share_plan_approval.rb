class AddMonthToGroupExpenseSharePlanApproval < ActiveRecord::Migration[6.1]
  def change
    add_column :group_expense_share_plan_approvals, :month, :date
  end
end
