class CreateDirectQuestionAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :direct_question_answers do |t|
      t.references :knowledge, null: false, foreign_key: true
      t.references :direct_question, null: false, foreign_key: true

      t.timestamps
    end
    Company::DirectQuestion.find_each do |dq|
      k = Company::Knowledge.find_by(question: dq.real_question)
      if k.present?
        dq.direct_question_answers.create!(knowledge: k)
      end
    end
  end
end
