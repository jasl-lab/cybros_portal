# frozen_string_literal: true

module Bi
  class ContractPrice < BiLocalTimeRecord
    self.table_name = 'CONTRACT_PRICE'

    def self.all_year_names
      Bi::ContractPrice.order(filingtime: :desc).where('filingtime >= ?', Date.new(2018,1,1))
        .pluck(:filingtime).collect { |d| d.year }.uniq
    end

    def self.all_month_names
      Bi::ContractPrice.order(filingtime: :desc).where('filingtime >= ?', Date.new(2018,1,1))
        .pluck(:filingtime).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
