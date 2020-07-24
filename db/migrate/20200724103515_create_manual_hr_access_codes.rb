class CreateManualHrAccessCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :manual_hr_access_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :hr_rolename
      t.string :org_code
      t.string :dept_code
      t.boolean :allow_list
      t.timestamps
    end
  end
end