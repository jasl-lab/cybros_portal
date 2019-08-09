# frozen_string_literal: true

module Bi
  class ContractHold < BiLocalTimeRecord
    self.table_name = "CONTRACT_HOLD"

    def self.all_month_names
      order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
