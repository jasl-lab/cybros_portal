class AddPhoneRegistrantToSmsPhoneMapping < ActiveRecord::Migration[6.1]
  def change
    add_column :sms_phone_mappings, :phone_registrant, :string
  end
end
