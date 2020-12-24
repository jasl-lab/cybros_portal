# frozen_string_literal: true

module Bi
  class ThCalendar < BiLocalTimeRecord
    self.table_name = 'TH_CALENDAR'

    def self.non_working_days(start_date, end_date)
      Bi::ThCalendar.order(datestamp: :asc)
        .where(iswork: 'N').where(datestamp: start_date..end_date)
        .pluck(:datestamp).reduce({}) do |h, s|
        h[s] = true
        h
      end
    end
  end
end
