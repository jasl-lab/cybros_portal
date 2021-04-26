# frozen_string_literal: true

module Company
  class SmsPhoneMapping < ApplicationRecord
    belongs_to :user, optional: true
  end
end
