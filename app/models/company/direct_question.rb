# frozen_string_literal: true

module Company
  class DirectQuestion < ApplicationRecord
    attr_accessor :real_question
    validates :question, presence: true

    validate :real_question_existing
    has_many :direct_question_answers, dependent: :destroy
    has_many :knowledges, through: :direct_question_answers
    before_create :create_direct_question_answer

    private

      def real_question_existing
        errors.add(:real_questions, :must_exist) unless Knowledge.where(question: real_question).exists?
      end

      def create_direct_question_answer
        direct_question_answers.build(knowledge: Knowledge.find_by!(question: real_question))
      end
  end
end
