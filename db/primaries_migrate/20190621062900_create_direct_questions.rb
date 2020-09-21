class CreateDirectQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :direct_questions do |t|
      t.string :question
      t.string :real_question

      t.timestamps
    end
  end
end
