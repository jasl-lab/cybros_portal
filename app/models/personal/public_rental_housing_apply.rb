# frozen_string_literal: true

module Personal
  class PublicRentalHousingApply < ApplicationRecord
    belongs_to :user
    has_one_attached :attachment

    include AttachmentValidate
    include Personal::CommonValidate
    validates :contract_belong_company, :contract_belong_company_code,
      :stamp_comment, presence: true
  end
end
