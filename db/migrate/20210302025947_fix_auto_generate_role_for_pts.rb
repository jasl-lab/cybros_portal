class FixAutoGenerateRoleForPts < ActiveRecord::Migration[6.1]
  def change
    change_column :part_time_split_access_codes, :auto_generated_role, :boolean, default: false, null: false
  end
end
