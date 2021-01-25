class RenameItKnowledgeToKnowledge < ActiveRecord::Migration[6.0]
  def change
    rename_table :it_knowledges, :knowledges
  end
end
