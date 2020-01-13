# frozen_string_literal: true

module Personal
  class ProofOfEmploymentApply < ApplicationRecord
    belongs_to :user
  end
end
