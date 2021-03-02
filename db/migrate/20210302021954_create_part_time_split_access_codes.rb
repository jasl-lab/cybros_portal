class CreatePartTimeSplitAccessCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :part_time_split_access_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :org_code
      t.string :dept_code
      t.string :auto_generated_role, null: false, default: false

      t.timestamps
    end
  end
end
