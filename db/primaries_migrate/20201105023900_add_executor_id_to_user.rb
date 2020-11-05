class AddExecutorIdToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :executor_id, :string
  end
end
