class AddGreatingTimeToWechatSession < ActiveRecord::Migration[6.0]
  def change
    add_column :wechat_sessions, :greating_time, :datetime
  end
end
