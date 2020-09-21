class CreateReportViewHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :report_view_histories do |t|
      t.string :controller_name
      t.string :action_name
      t.references :user, null: false, foreign_key: true
      t.datetime :created_at, null: false
    end
  end
end
