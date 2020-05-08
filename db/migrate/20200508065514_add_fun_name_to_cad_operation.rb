class AddFunNameToCadOperation < ActiveRecord::Migration[6.0]
  def change
    add_column :cad_operations, :seg_name, :string
    add_column :cad_operations, :seg_function, :string
  end
end
