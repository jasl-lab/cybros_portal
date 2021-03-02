class CreatePartTimeSpecialAccessCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :part_time_special_access_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :org_code
      t.boolean :auto_generated_role, null: false, default: false

      t.timestamps
    end
  end
end
