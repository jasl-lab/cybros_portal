class AddSessionKeyToWechatUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :wechat_users, :session_key, :string, :default => ''
  end
end
