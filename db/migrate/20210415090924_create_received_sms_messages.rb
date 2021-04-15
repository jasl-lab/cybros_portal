class CreateReceivedSmsMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :received_sms_messages do |t|
      t.string :receive_id
      t.string :content

      t.timestamps
    end
  end
end
