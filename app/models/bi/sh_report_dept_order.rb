# frozen_string_literal: true

module Bi
  class ShReportDeptOrder < BiLocalTimeRecord
    self.table_name = "SH_REPORT_DEPT_ORDER"

    def self.all_deptcodes_in_order
      @_all_deptcodes_in_order ||= all.order(:dept_asc).pluck(:deptcode)
    end

    def self.all_deptnames
      @_all_deptnames ||= all.reduce({}) do |h, d|
        h[d.deptcode] = d.deptname
        h
      end
    end

    def self.mapping2deptname
      @_mapping2deptname ||= all.reduce({}) do |h, s|
        h[s.deptname] = s.deptcode
        h
      end
    end
  end
end
