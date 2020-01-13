# frozen_string_literal: true

module Personal
  class CopyOfBusinessLicenseApply < ApplicationRecord
    belongs_to :user
  end
end
