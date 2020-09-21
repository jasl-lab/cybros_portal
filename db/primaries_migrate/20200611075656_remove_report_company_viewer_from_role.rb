class RemoveReportCompanyViewerFromRole < ActiveRecord::Migration[6.0]
  def change
    remove_column :roles, :report_company_viewer, :boolean
  end
end
