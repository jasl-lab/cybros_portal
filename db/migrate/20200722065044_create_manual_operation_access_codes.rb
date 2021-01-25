class CreateManualOperationAccessCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :manual_operation_access_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :code
      t.string :org_code
      t.string :dept_code
      t.string :title
      t.integer :job_level

      t.timestamps
    end
  end
end
