# frozen_string_literal: true

module Bi
  class ContractProductionDetail < BiLocalTimeRecord
    self.table_name = "CONTRACT_PRODUCTION_DETAIL"

    def self.last_available_date(end_of_month)
      available_date = where("date <= ?", end_of_month).order(date: :desc).first&.date
      available_date = order(date: :desc).first.date if available_date.nil?
      available_date
    end
  end
end
