# frozen_string_literal: true

module Company
  class SmsPhoneMapping < ApplicationRecord
    validates_presence_of :receive_id
    validates_uniqueness_of :receive_id
    belongs_to :user, optional: true
  end
end
