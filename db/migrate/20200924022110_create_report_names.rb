class CreateReportNames < ActiveRecord::Migration[6.0]
  def change
    create_table :report_names do |t|
      t.string :controller_name
      t.string :report_name

      t.timestamps
    end
  end
end
