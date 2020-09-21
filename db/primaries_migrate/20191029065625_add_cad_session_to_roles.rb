class AddCadSessionToRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :cad_session, :boolean
  end
end
