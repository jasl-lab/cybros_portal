# frozen_string_literal: true

module Personal
  class CopyOfBusinessLicenseApply < ApplicationRecord
    belongs_to :user
    has_one_attached :attachment

    include AttachmentValidate
  end
end
