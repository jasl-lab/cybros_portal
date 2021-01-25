class RemoveRealQuestionFromDirectQuestion < ActiveRecord::Migration[6.0]
  def change
    remove_column :direct_questions, :real_question, :string
  end
end
