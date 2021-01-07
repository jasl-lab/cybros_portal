# frozen_string_literal: true

module Hrdw
  class StfreinstateBi < HrdwLocalTimeRecord
    self.table_name = 'HRDW_STFREINSTATE_BI'

    def self.hr_staff_per_dept_code_by_date(org_code, end_of_month)
      where(enddate: nil).or(where('enddate >= ?', end_of_month))
        .where('begindate <= ?', end_of_month)
        .where(orgcode: org_code)
        .where.not(trnsevent: '离职').where(glbdef1: '生产')
        .group(:deptcode)
        .select('deptcode, count(*) staff_now')
        .reduce({}) do |h, s|
          h[s.deptcode] = s.staff_now
          h
        end
    end
  end
end
