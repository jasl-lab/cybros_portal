# frozen_string_literal: true

module Bi
  class ContractPrice < BiLocalTimeRecord
    self.table_name = 'CONTRACT_PRICE'

    def self.all_year_names
      Bi::ContractPrice.order(filingtime: :desc).where('filingtime >= ?', Date.new(2016,1,1))
        .pluck(:filingtime).collect { |d| d.year }.uniq
    end

    def self.all_month_names
      Bi::ContractPrice.order(filingtime: :desc).where('filingtime >= ?', Date.new(2016,1,1))
        .pluck(:filingtime).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.住宅方案公建施工图_cateogries_4
      %w[住宅方案 住宅施工图 公建方案 公建施工图]
    end
  end
end
