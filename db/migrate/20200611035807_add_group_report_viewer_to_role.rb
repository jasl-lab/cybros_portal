class AddGroupReportViewerToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :group_report_viewer, :boolean, default: false
  end
end
