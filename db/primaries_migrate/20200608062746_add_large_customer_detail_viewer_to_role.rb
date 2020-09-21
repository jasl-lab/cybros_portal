class AddLargeCustomerDetailViewerToRole < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :large_customer_detail_viewser, :boolean
  end
end
