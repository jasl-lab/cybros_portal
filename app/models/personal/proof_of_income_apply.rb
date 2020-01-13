# frozen_string_literal: true

module Personal
  class ProofOfIncomeApply < ApplicationRecord
    belongs_to :user
  end
end
