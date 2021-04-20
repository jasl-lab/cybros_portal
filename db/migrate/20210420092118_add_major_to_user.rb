class AddMajorToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :major_code, :string
    add_column :users, :major_name, :string
  end
end
