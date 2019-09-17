# frozen_string_literal: true

module Company
  class DirectQuestion < ApplicationRecord
    validates :question, :real_question, presence: true

    validate :real_question_existing
    has_many :direct_question_answers, dependent: :destroy
    has_many :knowledges, through: :direct_question_answers

    private

    def real_question_existing
      errors.add(:real_question, :must_exist) unless Knowledge.where(question: real_question).exists?
    end
  end
end
