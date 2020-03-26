# frozen_string_literal: true

module Bi
  class YearReportHistory < BiLocalTimeRecord
    self.table_name = 'YEAR_REPORT_HISTORY'

    def self.year_options
      Bi::YearReportHistory.order(year: :desc).pluck(:year).uniq
    end

    def self.month_names
      Bi::YearReportHistory.order(month: :desc).pluck(:month).uniq
    end
  end
end
