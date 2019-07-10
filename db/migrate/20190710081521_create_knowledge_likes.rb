class CreateKnowledgeLikes < ActiveRecord::Migration[6.0]
  def change
    create_table :knowledge_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :like_count

      t.timestamps
    end
  end
end
