class AddStatusToOfficialSealUsages < ActiveRecord::Migration[6.0]
  def change
    add_column :copy_of_business_license_applies, :status, :string
    add_column :proof_of_employment_applies, :status, :string
    add_column :proof_of_income_applies, :status, :string
    add_column :public_rental_housing_applies, :status, :string
  end
end
