# frozen_string_literal: true

module Bi
  class ContractSignDetailDate < BiLocalTimeRecord
    self.table_name = 'CONTRACT_SIGN_DETAIL_DATE'

    def self.all_month_names
      order(filingtime: :desc).pluck(:filingtime).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.all_org_long_names
      select(:orgname).distinct.pluck(:orgname)
    end
  end
end
