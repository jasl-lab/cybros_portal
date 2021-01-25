class AddPreSsoIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :pre_sso_id, :string
  end
end
