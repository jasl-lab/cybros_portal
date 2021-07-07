# frozen_string_literal: true

module Market
  class MarketEntry < ApplicationRecord
    belongs_to :user
    delegated_type :entryable, types: %w[ BorrowWorkforce SubcontractTask ]
  end
end
