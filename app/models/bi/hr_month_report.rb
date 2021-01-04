# frozen_string_literal: true

module Bi
  class HrMonthReport < BiLocalTimeRecord
    self.table_name = 'HR_MONTH_REPORT'

    def self.按月子公司一线人数(month_number, org_codes)
      select("DATE_FORMAT(savedate, '%Y') year, sum(realdate)/max(deptdate) avg_work_no")
        .where(orgcode: org_codes)
        .where("DATE_FORMAT(savedate, '%m') = ? ", month_number)
        .group("DATE_FORMAT(savedate, '%Y')")
    end
  end
end
