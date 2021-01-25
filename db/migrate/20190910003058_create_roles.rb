class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles do |t|
      t.string :role_name
      t.boolean :report_viewer
      t.boolean :report_reviewer
      t.boolean :knowledge_maintainer

      t.timestamps
    end

    create_table :role_users do |t|
      t.references :role, null: false
      t.references :user, null: false

      t.timestamps null: false
    end
  end
end
