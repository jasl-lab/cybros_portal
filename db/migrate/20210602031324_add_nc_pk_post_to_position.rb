class AddNcPkPostToPosition < ActiveRecord::Migration[6.1]
  def change
    add_column :positions, :nc_pk_post, :string
    remove_column :positions, :pk_poststd, :string
  end
end
