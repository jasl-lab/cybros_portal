# frozen_string_literal: true

module Bi
  class ShStaffCount < BiLocalTimeRecord
    self.table_name = "SH_STAFF_COUNT"

    def self.last_available_f_month
      order(f_month: :desc).first.f_month
    end

    def self.staff_per_dept_name
      @staff_per_dept_name ||= where(f_month: last_available_f_month).reduce({}) do |h, s|
        h[s.deptname] = s.avgamount
        h
      end
    end
  end
end
