class AddNameParamToNameCardApply < ActiveRecord::Migration[6.0]
  def change
    add_column :name_card_applies, :thickness, :string
    add_column :name_card_applies, :back_color, :string
  end
end
