class AddProjectMapContractDownloadToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :project_map_contract_download, :boolean, default: false, null: false
  end
end
