# frozen_string_literal: true

module Cad
  class CadOperation < ApplicationRecord
    validates :session_id, :cmd_name, :cmd_seconds, presence: true
    validates_numericality_of :cmd_seconds, only_integer: true
    belongs_to :user
  end
end
