class RenameExecutorIdForUser < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :executor_id, :wecom_id
  end
end
