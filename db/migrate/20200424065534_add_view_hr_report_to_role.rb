class AddViewHrReportToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :hr_report_admin, :boolean
    add_column :roles, :hr_report_viewer, :boolean
    add_column :roles, :hr_report_writer, :boolean
  end
end
