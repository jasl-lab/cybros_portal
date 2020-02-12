# frozen_string_literal: true

module Personal
  class PublicRentalHousingApply < ApplicationRecord
    belongs_to :user
    has_one_attached :attachment
  end
end
