class AddClerkCodeToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :clerk_code, :string
    add_column :users, :chinese_name, :string
  end
end
