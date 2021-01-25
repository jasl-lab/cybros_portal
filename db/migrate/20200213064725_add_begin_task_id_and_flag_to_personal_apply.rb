class AddBeginTaskIdAndFlagToPersonalApply < ActiveRecord::Migration[6.0]
  def change
    add_column :copy_of_business_license_applies, :begin_task_id, :string
    add_column :copy_of_business_license_applies, :backend_in_processing, :boolean
    add_column :copy_of_business_license_applies, :bpm_message, :text
    add_column :proof_of_employment_applies, :begin_task_id, :string
    add_column :proof_of_employment_applies, :backend_in_processing, :boolean
    add_column :proof_of_employment_applies, :bpm_message, :text
    add_column :proof_of_income_applies, :begin_task_id, :string
    add_column :proof_of_income_applies, :backend_in_processing, :boolean
    add_column :proof_of_income_applies, :bpm_message, :text
    add_column :public_rental_housing_applies, :begin_task_id, :string
    add_column :public_rental_housing_applies, :backend_in_processing, :boolean
    add_column :public_rental_housing_applies, :bpm_message, :text
  end
end
