module Company
  class DirectQuestion < ApplicationRecord
    validates :question, :real_question, presence: true

    validate :real_question_existing

    private

    def real_question_existing
      errors.add(:real_question, :must_exist) unless Knowledge.where(question: real_question).exists?
    end
  end
end
