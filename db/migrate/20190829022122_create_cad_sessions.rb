class CreateCadSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :cad_sessions do |t|
      t.string :session
      t.string :operation
      t.string :ip_address
      t.string :mac_address
      t.references :user

      t.timestamps
    end
  end
end
