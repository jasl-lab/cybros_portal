class CreateMarketEntries < ActiveRecord::Migration[6.1]
  def change
    create_table :market_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :entryable_type
      t.bigint :entryable_id
      t.datetime :expire_time

      t.timestamps
    end
    create_table :borrow_workforces do |t|
      t.string :project_item_code
      t.integer :approximate_cost
      t.text :additional_info

      t.timestamps
    end
    create_table :subcontract_tasks do |t|
      t.string :project_item_code
      t.integer :approximate_cost
      t.text :subcontract_content

      t.timestamps
    end
  end
end
