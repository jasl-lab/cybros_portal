class CreateCybrosDashbaord < ActiveRecord::Migration[6.0]
  def change
    create_table :cybros_dashbaords do |t|
      t.integer :current_employee_hc
      t.integer :average_employee_hc
      t.integer :this_month_foreign_recruits
      t.integer :this_month_departures
    end
  end
end
