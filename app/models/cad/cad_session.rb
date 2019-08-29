# frozen_string_literal: true

module Cad
  class CadSession < ApplicationRecord
    validates :session, :operation, :ip_address, :mac_address, presence: true
    belongs_to :user
  end
end
