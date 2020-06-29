# frozen_string_literal: true

module Bi
  class ContractPrice < BiLocalTimeRecord
    self.table_name = 'CONTRACT_PRICE'

    def self.all_year_names
      Bi::ContractPrice.order(filingtime: :desc).where('filingtime >= ?', Date.new(2016,1,1))
        .pluck(:filingtime).collect { |d| d.year }.uniq
    end
  end
end
