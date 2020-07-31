# frozen_string_literal: true

module Bi
  class WorkHoursCountDetailDept < BiLocalTimeRecord
    self.table_name = "WORK_HOURS_COUNT_DETAIL_DEPT"

    def self.all_month_names
      Bi::WorkHoursCountDetailDept.order(date: :desc).distinct.pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
