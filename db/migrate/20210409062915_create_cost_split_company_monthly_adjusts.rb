class CreateCostSplitCompanyMonthlyAdjusts < ActiveRecord::Migration[6.1]
  def change
    create_table :cost_split_company_monthly_adjusts do |t|
      t.string :to_split_company_code
      t.date :month
      t.decimal :group_cost_adjust, default: 0
      t.decimal :shanghai_area_cost_adjust, default: 0
      t.decimal :shanghai_hq_cost_adjust, default: 0
      t.references :user

      t.timestamps
    end
  end
end
