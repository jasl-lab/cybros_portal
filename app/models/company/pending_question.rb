# frozen_string_literal: true

module Company
  class PendingQuestion < ApplicationRecord
    belongs_to :user
    belongs_to :owner, class_name: 'User', optional: true
  end
end
