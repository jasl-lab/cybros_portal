class AddCompanyNameToDepartment < ActiveRecord::Migration[6.0]
  def change
    add_column :departments, :company_name, :string
  end
end
