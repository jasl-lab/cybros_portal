class CreateCadOperations < ActiveRecord::Migration[6.0]
  def change
    create_table :cad_operations do |t|
      t.string :session_id
      t.string :cmd_name
      t.integer :cmd_seconds
      t.text :cmd_data
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
