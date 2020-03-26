# frozen_string_literal: true

module Bi
  class YearReportHistory < BiLocalTimeRecord
    self.table_name = 'YEAR_REPORT_HISTORY'

    def self.year_month_names
      Bi::YearReportHistory.order(year_month: :desc).pluck(:year_month).uniq
    end
  end
end
