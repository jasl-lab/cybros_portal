class AddCodeToPersonalApplies < ActiveRecord::Migration[6.0]
  def change
    add_column :copy_of_business_license_applies, :belong_company_code, :string
    add_column :copy_of_business_license_applies, :belong_department_code, :string
    add_column :copy_of_business_license_applies, :contract_belong_company_code, :string
    add_column :proof_of_employment_applies, :belong_company_code, :string
    add_column :proof_of_employment_applies, :belong_department_code, :string
    add_column :proof_of_employment_applies, :contract_belong_company_code, :string
    add_column :proof_of_income_applies, :belong_company_code, :string
    add_column :proof_of_income_applies, :belong_department_code, :string
    add_column :proof_of_income_applies, :contract_belong_company_code, :string
    add_column :public_rental_housing_applies, :belong_company_code, :string
    add_column :public_rental_housing_applies, :belong_department_code, :string
    add_column :public_rental_housing_applies, :contract_belong_company_code, :string
  end
end
