class CreateItKnowledges < ActiveRecord::Migration[6.0]
  def change
    create_table :it_knowledges do |t|
      t.string :application
      t.string :category
      t.string :question
      t.text :answer

      t.timestamps
    end
  end
end
