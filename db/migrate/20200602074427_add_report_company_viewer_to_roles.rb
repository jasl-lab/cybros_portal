class AddReportCompanyViewerToRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :report_company_viewer, :boolean
    add_column :roles, :report_company_detail_viewer, :boolean
  end
end
