# frozen_string_literal: true

module Market
  module Entryable
    extend ActiveSupport::Concern

    included do
      has_one :market_entry, as: :entryable, touch: true
    end
  end
end
