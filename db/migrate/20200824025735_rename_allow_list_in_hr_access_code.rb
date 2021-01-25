class RenameAllowListInHrAccessCode < ActiveRecord::Migration[6.0]
  def change
    rename_column :manual_hr_access_codes, :allow_list, :auto_generated_role
    change_column_default :manual_hr_access_codes, :auto_generated_role, false
  end
end
