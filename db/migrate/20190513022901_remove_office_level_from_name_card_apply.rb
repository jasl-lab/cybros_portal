class RemoveOfficeLevelFromNameCardApply < ActiveRecord::Migration[6.0]
  def change
    remove_column :name_card_applies, :office_level
  end
end
