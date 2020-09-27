# frozen_string_literal: true

module Bi
  class SubCompanyNeedReceiveSignDetail < BiLocalTimeRecord
    self.table_name = 'SUB_COMPANY_NEED_RECEIVE_SIGN_DETAIL'

    def self.all_month_names
      @all_month_names ||= order(date: :desc).distinct.pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.all_org_long_names(end_of_date)
      where(date: end_of_date).select(:orgname)
        .where.not(orgname: '上海天华嘉易建筑设计有限公司')
        .distinct.pluck(:orgname).uniq
    end
  end
end
