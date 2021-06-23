class AddInGenerateToRole < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :in_generating, :boolean, null: false, default: false
  end
end
