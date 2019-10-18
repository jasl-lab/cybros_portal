# frozen_string_literal: true

module Bi
  class ContractProductionDept < BiLocalTimeRecord
    self.table_name = "CONTRACT_PRODUCTION_DEPT"

    def self.last_available_date(end_of_month)
      available_date = where("filingtime <= ?", end_of_month).order(filingtime: :desc).first&.filingtime
      available_date = order(filingtime: :desc).first.filingtime if available_date.nil?
      available_date
    end
  end
end
