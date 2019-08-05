# frozen_string_literal: true

module Bi
  class ShRefreshRate < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "SH_REFRESH_RATE"

    def self.all_month_names
      Bi::ShRefreshRate.order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.person_count_by_department(target_date)
      deps = where(date: target_date)
        .select('deptcode, count(work_no) work_no')
        .group(:deptcode).order(deptcode: :asc)
      @_person_count_by_department = deps.reduce({}) do |h, s|
        h[s.deptcode] = s.work_no
        h
      end
    end

    def self.person_by_department_in_sh(target_date, show_all_dept = false)
      lad = where(date: target_date)
      lad = lad.where(deptcode: Bi::ShReportDeptOrder.all_deptcodes_in_order) unless show_all_dept
      lad = lad.joins("LEFT JOIN SH_REPORT_DEPT_ORDER ON SH_REPORT_DEPT_ORDER.deptcode = SH_REFRESH_RATE.deptcode")
        .order('SH_REPORT_DEPT_ORDER.dept_asc')
      h = {}
      department_code_in_order = lad.collect(&:deptcode).uniq
      department_code_in_order.each do |deptcode|
        h[deptcode] = lad.find_all { |rr| rr.deptcode == deptcode }
      end
      h
    end
  end
end
