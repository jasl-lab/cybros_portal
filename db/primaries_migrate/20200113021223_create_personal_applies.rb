class CreatePersonalApplies < ActiveRecord::Migration[6.0]
  def change
    create_table :proof_of_employment_applies do |t|
      t.references :user
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment

      t.timestamps
    end
    create_table :proof_of_income_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment

      t.timestamps
    end
    create_table :copy_of_business_license_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment

      t.timestamps
    end
    create_table :public_rental_housing_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment

      t.timestamps
    end
  end
end
