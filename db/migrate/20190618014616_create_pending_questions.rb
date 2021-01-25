class CreatePendingQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :pending_questions do |t|
      t.references :user, null: false
      t.string :question

      t.timestamps
    end
  end
end
