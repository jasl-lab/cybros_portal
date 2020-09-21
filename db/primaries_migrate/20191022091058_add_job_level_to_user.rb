class AddJobLevelToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :job_level, :string
  end
end
