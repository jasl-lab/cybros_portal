# frozen_string_literal: true

module Company
  class OfficialStampUsageApply < ApplicationRecord
    belongs_to :user
    has_one_attached :attachment

    include AttachmentValidate
    include Personal::CommonValidate
    serialize :application_subclasses, Array
  end
end
