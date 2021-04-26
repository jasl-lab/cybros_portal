class CreateSmsPhoneMappings < ActiveRecord::Migration[6.1]
  def change
    create_table :sms_phone_mappings do |t|
      t.string :receive_id
      t.references :user, index: false
      t.string :user_mobile

      t.timestamps
    end
  end
end
