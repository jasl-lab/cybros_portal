# frozen_string_literal: true

module Bi
  class WorkHoursCountCombine < BiLocalTimeRecord
    self.table_name = 'WORK_HOURS_COUNT_COMBINE'
    self.inheritance_column = 'column_type_is_not_type'

    def self.last_available_date
      select(:date).order(date: :desc).first.date
    end

    def self.lunch_count_hash(company_code, beginning_of_day, end_of_day)
      lunch_count = select('ncworkno, type1, type2, type22, type24')
        .where('type1 > 0')
        .where(date: beginning_of_day..end_of_day, orgcode: company_code)

      lunch_work_count = lunch_count.where(iswork: 1).reduce({}) do |h, l|
        t = (l.type1.to_f + l.type2.to_f - l.type24.to_f) >= 10 ? 1 : 0
        if h[l.ncworkno].present?
          h[l.ncworkno] = h[l.ncworkno] + t
        else
          h[l.ncworkno] = t
        end
        h
      end

      lunch_non_work_count = lunch_count.where(iswork: 0).reduce({}) do |h, l|
        cal_type = l.type1.to_f + l.type22.to_f
        t = if cal_type >= 8
          2
        elsif cal_type >= 4 && cal_type < 8
          1
        else
          0
        end
        if h[l.ncworkno].present?
          h[l.ncworkno] = h[l.ncworkno] + t
        else
          h[l.ncworkno] = t
        end
        h
      end

      return lunch_work_count, lunch_non_work_count
    end

    def self.fill_rate_hash(company_code, dept_code, beginning_of_day, end_of_day, view_deptcode_sum)
      fill_rate_numerator = select('ncworkno, COUNT(*) realhours_count')
        .where(date: beginning_of_day..end_of_day, orgcode: company_code)
        .where('type1 > 0 OR type2 > 0 OR type4 > 0 ')
        .group(:ncworkno)
      fill_rate_numerator = if view_deptcode_sum && dept_code
        fill_rate_numerator.where(deptcode_sum: dept_code)
      elsif dept_code
        fill_rate_numerator.where(deptcode: dept_code)
      else
        fill_rate_numerator
      end.reduce({}) do |h, s|
        h[s.ncworkno] = s.realhours_count
        h
      end

      fill_rate_denominator = select('ncworkno, COUNT(needhours) needhours_count')
        .where(date: beginning_of_day..end_of_day, orgcode: company_code)
        .where('needhours > 0')
        .group(:ncworkno)
      fill_rate_denominator = if view_deptcode_sum && dept_code
        fill_rate_denominator.where(deptcode_sum: dept_code)
      elsif dept_code
        fill_rate_denominator.where(deptcode: dept_code)
      else
        fill_rate_denominator
      end.reduce({}) do |h, s|
        h[s.ncworkno] = s.needhours_count
        h
      end

      return fill_rate_numerator, fill_rate_denominator
    end
  end
end
