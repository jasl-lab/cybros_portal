module Bi
  class RefreshRate < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'REFRESH_RATE'

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

    def self.person_by_department
      return @_person_by_department if @_person_by_department.present?

      lad = where(date: last_available_date)
      h = {}
      person_count_by_department.each do |a|
        deptcode = a.first
        h[deptcode] ||= []
        h[deptcode] << lad.find_all { |rr| rr.deptcode == deptcode }
      end
      @_person_by_department = h
    end
  end
end
