class AddProjectCodeToCadOperation < ActiveRecord::Migration[6.1]
  def change
    add_column :cad_operations, :seg_project_code, :string
    add_column :cad_sessions, :jwt_aud, :string
  end
end
