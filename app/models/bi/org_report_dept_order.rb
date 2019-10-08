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

    def self.dept_code_by_short_name(company_long_name, available_date)
      where(组织: company_long_name)
        .where("是否显示 = '1'").where("开始时间 <= ?", available_date)
        .where("结束时间 IS NULL OR 结束时间 >= ?", available_date)
    end
  end
end
