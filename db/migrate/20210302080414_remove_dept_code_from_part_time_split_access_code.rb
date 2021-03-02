class RemoveDeptCodeFromPartTimeSplitAccessCode < ActiveRecord::Migration[6.1]
  def change
    remove_column :part_time_split_access_codes, :dept_code, :string
  end
end
