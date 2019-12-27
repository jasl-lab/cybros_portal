class AddViewProjectMapToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :project_map_viewer, :boolean
  end
end
