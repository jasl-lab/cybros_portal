class ChangeCadOperation < ActiveRecord::Migration[6.0]
  def change
    change_column(:cad_operations, :cmd_data, :json)
  end
end
