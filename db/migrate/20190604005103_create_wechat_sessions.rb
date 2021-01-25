class CreateWechatSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :wechat_sessions do |t|
      t.string :openid, null: false
      t.timestamps null: false
    end
    add_index :wechat_sessions, :openid, unique: true
  end
end
