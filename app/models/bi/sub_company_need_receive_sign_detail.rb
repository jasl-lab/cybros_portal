# frozen_string_literal: true

module Bi
  class SubCompanyNeedReceiveSignDetail < BiLocalTimeRecord
    self.table_name = 'SUB_COMPANY_NEED_RECEIVE_SIGN_DETAIL'

    def self.all_month_names
      @all_month_names ||= order(date: :desc).distinct.pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.all_org_long_names(end_of_date)
      where(date: end_of_date)
        .joins('INNER JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_NEED_RECEIVE_SIGN_DETAIL.orgcode')
        .select('ORG_ORDER.org_order, SUB_COMPANY_NEED_RECEIVE_SIGN_DETAIL.orgname')
        .order('ORG_ORDER.org_order ASC')
        .where.not(orgname: '上海天华嘉易建筑设计有限公司')
        .pluck(:orgname)
        .uniq
    end
  end
end
