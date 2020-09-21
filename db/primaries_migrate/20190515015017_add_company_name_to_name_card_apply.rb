class AddCompanyNameToNameCardApply < ActiveRecord::Migration[6.0]
  def change
    add_column :name_card_applies, :company_name, :string
    add_column :name_card_applies, :en_company_name, :string
  end
end
