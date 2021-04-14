class AddPerPageToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :per_page, :integer, default: 12 # same as kaminari config
    add_column :users, :open_in_new_tab, :boolean, default: false
  end
end
