class RenameColumnToMoreGeneral < ActiveRecord::Migration[6.0]
  def change
    rename_column :knowledges, :application, :category_1
    rename_column :knowledges, :category, :category_2
    add_column :knowledges, :category_3, :string
  end
end
