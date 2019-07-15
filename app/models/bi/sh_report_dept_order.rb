module Bi
  class ShReportDeptOrder < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'SH_REPORT_DEPT_ORDER'

    def self.dept_names
      @dept_names ||= all.reduce({}) do |h, d|
        h[d.deptcode] = d.deptname
        h
      end
    end

    def self.all_deptcodes
      all.pluck(:deptcode)
    end
  end
end
