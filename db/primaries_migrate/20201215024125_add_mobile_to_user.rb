class AddMobileToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :mobile, :string
  end
end
