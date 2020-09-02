# frozen_string_literal: true

module Bi
  class CrmSacontract < BiLocalTimeRecord
    self.table_name = 'V_TH_RP_CRM_SACONTRACT'

    def self.all_year_names
      Bi::CrmSacontract.order(filingtime: :desc).where('filingtime >= ?', Date.new(2018,1,1))
        .pluck(:filingtime).collect { |d| d.year }.uniq
    end

    def self.all_month_names
      Bi::CrmSacontract.order(filingtime: :desc).where('filingtime >= ?', Date.new(2018,1,1))
        .pluck(:filingtime).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
