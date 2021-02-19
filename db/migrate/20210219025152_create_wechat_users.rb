class CreateWechatUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :wechat_users do |t|
      t.string :app_id, null: false, comment: '微信APPID'
      t.string :open_id, null: false, comment: '微信用户OPENID'
      t.string :union_id, null: true, default: nil, comment: '微信UNIONID', index: true
      t.string :mobile, null: false, default: '', comment: '手机号', index: true
      t.string :nick_name, null: false, default: '', comment: '昵称'
      t.string :avatar_url, null: false, default: '', comment: '头像'
      t.integer :gender, null: false, default: 0, comment: '性别 0：未知、1：男、2：女'
      t.string :province, null: false, default: '', comment: '省'
      t.string :city, null: false, default: '', comment: '市'
      t.string :country, null: false, default: '', comment: '国家'
      t.references :user, null: true, default: nil, foreign_key: true
      t.timestamps
    end
    add_index :wechat_users, [:app_id, :open_id], unique: true
  end
end
