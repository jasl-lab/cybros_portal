# frozen_string_literal: true

module Company
  class KnowledgeLike < ApplicationRecord
    belongs_to :user
  end
end
