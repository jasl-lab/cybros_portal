class AddBackendProcessiongToNameCardApply < ActiveRecord::Migration[6.0]
  def change
    add_column :name_card_applies, :backend_in_processing, :boolean, default: false
  end
end
