# frozen_string_literal: true

module Bi
  class ContractHoldSignDetail < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "CONTRACT_HOLD_SIGN_DETAIL"
  end
end
