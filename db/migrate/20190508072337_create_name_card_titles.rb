class CreateNameCardTitles < ActiveRecord::Migration[6.0]
  def change
    create_table :name_card_white_titles do |t|
      t.string :original_title
      t.string :required_title

      t.timestamps
    end
    create_table :name_card_black_titles do |t|
      t.string :original_title
      t.string :required_title

      t.timestamps
    end
  end
end
