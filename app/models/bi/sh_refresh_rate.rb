module Bi
  class ShRefreshRate < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'SH_REFRESH_RATE'

    def self.last_available_date
      order(date: :desc).first.date
    end

    def self.person_count_by_department
      return @_person_count_by_department if @_person_count_by_department.present?

      deps = where(date: last_available_date)
        .select('deptcode, count(work_no) work_no')
        .group(:deptcode).order(deptcode: :asc)
      @_person_count_by_department = deps.reduce({}) do |h, s|
        h[s.deptcode] = s.work_no
        h
      end
    end

    def self.person_by_department_in_sh
      return @_person_by_department_in_sh if @_person_by_department_in_sh.present?

      lad = where(date: last_available_date)
        .joins("LEFT JOIN SH_REPORT_DEPT_ORDER ON SH_REPORT_DEPT_ORDER.deptcode = SH_REFRESH_RATE.deptcode")
        .order('SH_REPORT_DEPT_ORDER.dept_asc')
      h = {}
      department_code_in_order = lad.collect(&:deptcode).uniq
      department_code_in_order.each do |deptcode|
        h[deptcode] = lad.find_all { |rr| rr.deptcode == deptcode }
      end
      @_person_by_department_in_sh = h
    end
  end
end
