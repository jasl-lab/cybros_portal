# frozen_string_literal: true

module Bi
  class WorkHoursDayCountDept < BiLocalTimeRecord
    self.table_name = 'WORK_HOURS_DAY_COUNT_DEPT'

    def self.last_available_date
      order(date: :desc).first.date
    end
  end
end
