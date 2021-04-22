class NewApproveDetailsForCostSplitCompanyMonthlyAdjust < ActiveRecord::Migration[6.1]
  def change
    create_table :cost_split_company_monthly_adjust_approve_details do |t|
      t.references :cost_split_company_monthly_adjust, null: false, foreign_key: true, index: { name: 'idx_company_monthly_adjust_approve_details_on_adjust_id'}
      t.string :clerk_code
      t.string :chinese_name
      t.string :approval_message
      t.string :biz_id
      t.string :step_label

      t.timestamps
    end
    remove_reference :cost_split_company_monthly_adjusts, :user
    remove_column :cost_split_company_monthly_adjusts, :approval_message, :string
  end
end
