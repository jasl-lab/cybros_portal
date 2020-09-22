class CreateCybrosDashboard < ActiveRecord::Migration[6.0]
  def change
    create_table :cybros_dashboards, comment: '管理驾驶舱' do |t|
      t.date :fill_at, comment: '数据填写日期'
      t.integer :current_employee_hc, comment: '现有人数'
      t.integer :average_employee_hc, comment: '平均人数'
      t.integer :this_month_foreign_recruits, comment: '本月外招人数'
      t.integer :this_month_departures, comment: '本月离职人数'
      t.integer :accumulative_foreign_recruits, comment: '累计外招人数'
      t.integer :accumulative_departures, comment: '累计离职人数'
      t.integer :estimated_onboard_in_month, comment: '预计当月入职人数'
      t.integer :turnover_rate, comment: '离职率'

      t.decimal :contract_amounts, comment: '生产合同额'
      t.decimal :predict_contracts, comment: '跟踪合同额'
      t.decimal :contract_amount_of_the_month, comment: '当月生产合同额'
      t.decimal :contract_amount_per_employee, comment: '全员人均生产合同额'
      t.decimal :contract_amount_per_worker, comment: '一线人均生产合同额'
      t.decimal :predict_contracts_per_employee, comment: '全员人均跟踪合同额'
      t.decimal :predict_contracts_per_worker, comment: '全员人均跟踪合同额'

      t.timestamps null: false
    end
  end
end
