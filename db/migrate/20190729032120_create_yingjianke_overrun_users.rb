class CreateYingjiankeOverrunUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :yingjianke_overrun_users do |t|
      t.datetime :time
      t.string :device
      t.decimal :stay_timespan

      t.timestamps
    end
  end
end
