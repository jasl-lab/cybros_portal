class CreateOfficialStampUsageApplies < ActiveRecord::Migration[6.0]
  def change
    create_table :official_stamp_usage_applies do |t|
      t.references :user
      t.string :employee_name
      t.string :clerk_code
      t.string :belong_company_name
      t.string :belong_company_code
      t.string :belong_department_name
      t.string :belong_department_code
      t.string :application_class
      t.string :application_subclass_list
      t.string :stamp_to_place
      t.string :stamp_comment
      t.string :begin_task_id
      t.string :backend_in_processing
      t.text :bpm_message
      t.string :status

      t.timestamps
    end
  end
end
