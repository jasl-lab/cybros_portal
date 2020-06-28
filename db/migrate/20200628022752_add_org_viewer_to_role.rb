class AddOrgViewerToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :org_viewer, :boolean, default: false
  end
end
