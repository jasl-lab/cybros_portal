# frozen_string_literal: true

module Bi
  class WorkHoursCountCombine < BiLocalTimeRecord
    self.table_name = 'WORK_HOURS_COUNT_COMBINE'
    self.inheritance_column = 'column_type_is_not_type'

    def self.last_available_date
      order(date: :desc).first.date
    end
  end
end
