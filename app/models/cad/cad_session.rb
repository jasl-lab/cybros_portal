# frozen_string_literal: true

module Cad
  class CadSession < ApplicationRecord
    validates :session, :operation, :ip_address, :mac_address, presence: true
    belongs_to :user
    has_many :operations, class_name: 'Cad::CadOperation', primary_key: :session, foreign_key: :session_id
  end
end
