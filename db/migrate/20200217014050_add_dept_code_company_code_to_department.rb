class AddDeptCodeCompanyCodeToDepartment < ActiveRecord::Migration[6.0]
  def change
    add_column :departments, :dept_code, :string
    add_column :departments, :company_code, :string
  end
end
