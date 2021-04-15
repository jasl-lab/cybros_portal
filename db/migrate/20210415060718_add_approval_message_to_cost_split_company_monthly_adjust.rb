class AddApprovalMessageToCostSplitCompanyMonthlyAdjust < ActiveRecord::Migration[6.1]
  def change
    add_column :cost_split_company_monthly_adjusts, :approval_message, :string
    add_column :cost_split_company_monthly_adjusts, :status, :string
  end
end
