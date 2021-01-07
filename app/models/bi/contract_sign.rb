# frozen_string_literal: true

module Bi
  class ContractSign < BiLocalTimeRecord
    self.table_name = 'CONTRACT_SIGN'

    def self.all_month_names
      Bi::ContractSign.order(filingtime: :desc).where('filingtime >= ?', Date.new(2019, 10, 1))
        .pluck(:filingtime).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.last_available_date(end_of_month)
      available_date = where('date <= ?', end_of_month).order(date: :desc).first&.date
      available_date = order(date: :desc).first.date if available_date.nil?
      available_date
    end
  end
end
