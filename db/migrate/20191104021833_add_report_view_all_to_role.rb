class AddReportViewAllToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :report_view_all, :boolean
  end
end
