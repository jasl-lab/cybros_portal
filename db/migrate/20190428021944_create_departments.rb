class CreateDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.integer :position

      t.timestamps null: false
    end

    create_table :department_users do |t|
      t.references :department, null: false
      t.references :user, null: false

      t.timestamps null: false
    end

    add_column :users, :position_title, :string
  end
end
