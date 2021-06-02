class CreateTianZhenLoginCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :tian_zhen_login_counts do |t|
      t.integer :login_count

      t.timestamps
    end
  end
end
