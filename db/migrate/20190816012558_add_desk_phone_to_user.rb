class AddDeskPhoneToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :desk_phone, :string
  end
end
