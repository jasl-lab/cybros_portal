# frozen_string_literal: true

module Bi
  class ShStaffCount < BiLocalTimeRecord
    self.table_name = 'SH_STAFF_COUNT'

    def self.last_available_f_month
      order(f_month: :desc).first.f_month
    end

    def self.staff_count_per_dept_code_by_date(end_of_month)
      d = where(f_month: end_of_month.to_s(:short_month))
      if d.blank?
        d = where(f_month: Bi::ShStaffCount.last_available_f_month)
      end
      d.reduce({}) do |h, s|
        h[s.deptcode] = s.avgamount
        h
      end
    end
  end
end
