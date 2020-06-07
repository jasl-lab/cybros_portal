# frozen_string_literal: true

module Bi
  class YearAvgStaff < BiLocalTimeRecord
    self.table_name = 'YEAR_AVG_STAFF'

    def self.last_available_date(end_of_month)
      available_date = where('f_month <= ?', end_of_month).order(f_month: :desc).first&.f_month
      available_date = order(f_month: :desc).first.f_month if available_date.nil?
      available_date
    end

    def self.available_data_at_month(end_of_month)
      available_date = last_available_date(end_of_month)
      where('f_month = ?', available_date)
    end

    def self.staff_per_orgcode_by_date_and_sum(end_of_month, view_sum)
      d1 = available_data_at_month(end_of_month)
      d2 = if view_sum
        d1.select('orgcode_sum orgcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:orgcode_sum)
      else
        d1.select('orgcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:orgcode)
      end
      d2.reduce({}) do |h, s|
        h[s.orgcode] = (s.sum_x / s.max_y.to_f)
        h
      end
    end

    def self.staff_per_orgcode_by_year_and_sum(end_of_month, view_sum)
      d1 = available_data_at_month(end_of_month)
      d2 = if view_sum
        d1.select('orgcode_sum orgcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:orgcode_sum)
      else
        d1.select('orgcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:orgcode)
      end
      d2.reduce({}) do |h, s|
        h[s.orgcode] = (s.sum_x / Time.days_in_year(end_of_month.year).to_f)
        h
      end
    end

    def self.staff_per_dept_code_by_date_and_sum(org_code, end_of_month, view_sum)
      d1 = available_data_at_month(end_of_month)
      d2 = if view_sum
        d1.where(orgcode: org_code).select('deptcode_sum deptcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:deptcode_sum)
      else
        d1.where(orgcode: org_code).select('deptcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:deptcode)
      end
      d2.reduce({}) do |h, s|
        h[s.deptcode] = (s.sum_x / s.max_y.to_f)
        h
      end
    end

     def self.staff_per_dept_code_by_year_and_sum(org_code, end_of_month, view_sum)
      d1 = available_data_at_month(end_of_month)
      d2 = if view_sum
        d1.where(orgcode: org_code).select('deptcode_sum deptcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:deptcode_sum)
      else
        d1.where(orgcode: org_code).select('deptcode, SUM(date_x) sum_x, MAX(date_y) max_y').group(:deptcode)
      end
      d2.reduce({}) do |h, s|
        h[s.deptcode] = (s.sum_x / Time.days_in_year(end_of_month.year).to_f)
        h
      end
    end
  end
end
