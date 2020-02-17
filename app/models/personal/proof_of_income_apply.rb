# frozen_string_literal: true

module Personal
  class ProofOfIncomeApply < ApplicationRecord
    belongs_to :user
    has_one_attached :attachment

    include AttachmentValidate
    include Personal::CommonValidate
  end
end
