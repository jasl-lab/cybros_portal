class AddDeptCategoryToPartTimeSplitAccessCode < ActiveRecord::Migration[6.1]
  def change
    add_column :part_time_split_access_codes, :dept_category, :string
  end
end
