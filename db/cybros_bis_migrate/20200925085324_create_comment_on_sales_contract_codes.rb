class CreateCommentOnSalesContractCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_on_sales_contract_codes do |t|
      t.string :sales_contract_code, null: false
      t.string :comment, null: false
      t.date :record_month, null: false

      t.timestamps
    end
  end
end
