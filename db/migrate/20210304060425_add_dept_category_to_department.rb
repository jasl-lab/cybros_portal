class AddDeptCategoryToDepartment < ActiveRecord::Migration[6.1]
  def change
    add_column :departments, :dept_category, :string
  end
end
