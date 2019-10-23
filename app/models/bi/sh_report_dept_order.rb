# frozen_string_literal: true

module Bi
  class ShReportDeptOrder < BiLocalTimeRecord
    self.table_name = "SH_REPORT_DEPT_ORDER"

    def self.mapping2deptname
      @_mapping2deptname ||= all.reduce({}) do |h, s|
        h[s.deptname] = s.deptcode
        h
      end
    end
  end
end
