# frozen_string_literal: true

module Bi
  class OrgReportDeptOrder < BiLocalTimeRecord
    self.table_name = "ORG_REPORT_DEPT_ORDER"

    def self.department_names
      @department_names ||= all.reduce({}) do |h, s|
        h[s.编号] = s.部门
        h
      end
    end
  end
end
