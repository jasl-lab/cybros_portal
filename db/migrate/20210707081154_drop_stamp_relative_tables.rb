class DropStampRelativeTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :official_stamp_usage_applies do |t|
      t.references :user
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_company_code
      t.string :belong_department_name
      t.string :belong_department_code
      t.string :application_class
      t.string :application_subclasses
      t.string :stamp_to_place
      t.string :stamp_comment
      t.string :begin_task_id
      t.string :backend_in_processing
      t.text :bpm_message
      t.string :status

      t.timestamps
    end
    drop_table :proof_of_employment_applies do |t|
      t.references :user
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment
      t.string :begin_task_id
      t.boolean :backend_in_processing
      t.text   :bpm_message
      t.string :belong_company_code
      t.string :belong_department_code
      t.string :contract_belong_company_code

      t.timestamps
    end
    drop_table :proof_of_income_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment
      t.string :begin_task_id
      t.boolean :backend_in_processing
      t.text   :bpm_message
      t.string :belong_company_code
      t.string :belong_department_code
      t.string :contract_belong_company_code

      t.timestamps
    end
    drop_table :copy_of_business_license_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment
      t.string :begin_task_id
      t.boolean :backend_in_processing
      t.text   :bpm_message
      t.string :belong_company_code
      t.string :belong_department_code
      t.string :contract_belong_company_code

      t.timestamps
    end
    drop_table :public_rental_housing_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_department_name
      t.string :contract_belong_company
      t.string :stamp_to_place
      t.string :stamp_comment
      t.string :begin_task_id
      t.boolean :backend_in_processing
      t.text   :bpm_message
      t.string :belong_company_code
      t.string :belong_department_code
      t.string :contract_belong_company_code

      t.timestamps
    end
  end
end
