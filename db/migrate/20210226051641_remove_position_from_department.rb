class RemovePositionFromDepartment < ActiveRecord::Migration[6.1]
  def change
    remove_column :departments, :position, type: :integer
  end
end
