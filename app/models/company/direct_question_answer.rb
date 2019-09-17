# frozen_string_literal: true

module Company
  class DirectQuestionAnswer < ApplicationRecord
    belongs_to :knowledge
    belongs_to :direct_question
  end
end
