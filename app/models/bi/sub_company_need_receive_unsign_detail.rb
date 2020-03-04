# frozen_string_literal: true

module Bi
  class SubCompanyNeedReceiveUnsignDetail < BiLocalTimeRecord
    self.table_name = 'SUB_COMPANY_NEED_RECEIVE_UNSIGN_DETAIL'

    def self.all_month_names
      order(date: :desc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.all_org_long_names(end_of_date)
      where(date: end_of_date).select(:orgname).distinct.pluck(:orgname)
    end
  end
end
