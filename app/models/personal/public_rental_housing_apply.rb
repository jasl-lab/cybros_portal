# frozen_string_literal: true

module Personal
  class PublicRentalHousingApply < ApplicationRecord
    belongs_to :user
  end
end
