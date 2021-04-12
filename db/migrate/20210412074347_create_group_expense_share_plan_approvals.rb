class CreateGroupExpenseSharePlanApprovals < ActiveRecord::Migration[6.1]
  def change
    create_table :group_expense_share_plan_approvals do |t|
      t.string :begin_task_id
      t.boolean :backend_in_processing, default: false
      t.string :status
      t.string :bpm_message
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_reference :cost_split_company_monthly_adjusts, :group_expense_share_plan_approval, index: { name: 'idx_monthly_adjusts_on_group_expense_share_plan_approval_id' }
  end
end
