class CreateManualCwAccessCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :manual_cw_access_codes do |t|
      t.references :user
      t.string :cw_rolename
      t.string :org_code
      t.string :dept_code
      t.boolean :auto_generated_role

      t.timestamps
    end
  end
end
