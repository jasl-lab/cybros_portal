class AddNameEmailToNameCardApply < ActiveRecord::Migration[6.0]
  def change
    add_column :name_card_applies, :chinese_name, :string
    add_column :name_card_applies, :email, :string
  end
end
