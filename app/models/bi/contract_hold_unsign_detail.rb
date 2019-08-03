# frozen_string_literal: true

module Bi
  class ContractHoldUnsignDetail < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "CONTRACT_HOLD_UNSIGN_DETAIL"
  end
end
