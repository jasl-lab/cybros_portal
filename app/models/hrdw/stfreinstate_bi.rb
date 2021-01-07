# frozen_string_literal: true

module Hrdw
  class StfreinstateBi < Bi::BiLocalTimeRecord
    self.table_name = 'HRDW.HRDW_STFREINSTATE_BI'

    def self.hr_staff_per_dept_code_by_date(org_code, target_date)
      where(enddate: nil).or(where('enddate >= ?', target_date))
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = HRDW.HRDW_STFREINSTATE_BI.deptcode and ORG_REPORT_DEPT_ORDER.开始时间 <= '#{target_date.to_date}' and (ORG_REPORT_DEPT_ORDER.结束时间 >= '#{target_date.to_date}' or ORG_REPORT_DEPT_ORDER.结束时间 is null)")
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, HRDW.HRDW_STFREINSTATE_BI.deptcode'))
        .where('begindate <= ?', target_date)
        .where(orgcode: org_code)
        .where.not(trnsevent: '离职').where(glbdef1: '生产')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, HRDW.HRDW_STFREINSTATE_BI.deptcode')
        .select('ORG_REPORT_DEPT_ORDER.部门排名, HRDW.HRDW_STFREINSTATE_BI.deptcode, count(*) staff_now')
        .reduce({}) do |h, s|
          h[s.deptcode] = s.staff_now
          h
        end
    end
  end
end
