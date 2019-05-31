class RemoveAnswerFromKnowledge < ActiveRecord::Migration[6.0]
  def change
    remove_column :knowledges, :answer, :string
  end
end
