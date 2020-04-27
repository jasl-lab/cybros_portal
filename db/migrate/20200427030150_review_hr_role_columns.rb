class ReviewHrRoleColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :roles, :hr_report_admin, :hr_group_rt_reader
    rename_column :roles, :hr_report_viewer, :hr_subsidiary_rt_reader
    add_column :roles, :hr_group_reader, :boolean
    add_column :roles, :hr_subsidiary_reader, :boolean
  end
end
