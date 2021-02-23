class AddEntryCompanyDateToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :entry_company_date, :date
  end
end
