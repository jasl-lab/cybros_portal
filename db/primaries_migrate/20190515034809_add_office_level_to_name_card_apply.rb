class AddOfficeLevelToNameCardApply < ActiveRecord::Migration[6.0]
  def change
    add_column :name_card_applies, :office_address, :string
    add_column :name_card_applies, :office_level, :string
    add_column :name_card_applies, :professional_title, :string
    add_column :name_card_applies, :en_professional_title, :string
  end
end
