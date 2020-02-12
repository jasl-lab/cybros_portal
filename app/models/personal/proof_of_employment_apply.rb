# frozen_string_literal: true

module Personal
  class ProofOfEmploymentApply < ApplicationRecord
    belongs_to :user
    has_one_attached :attachment

    include AttachmentValidate
  end
end
