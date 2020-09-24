class RemoveTimestampsFromReportNames < ActiveRecord::Migration[6.0]
  def change
    remove_column :report_names, :created_at, :string
    remove_column :report_names, :updated_at, :string
  end
end
