module Bi
  class ContractHold < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'SH_CONTRACT_HOLD'

    def self.last_available_date
      @_last_available_date ||= order(date: :desc).first.date
    end
  end
end
