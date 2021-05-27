class AddBatteryAndChargingToSmsPhoneMapping < ActiveRecord::Migration[6.1]
  def change
    add_column :sms_phone_mappings, :battery, :integer
    add_column :sms_phone_mappings, :charging, :boolean
  end
end
