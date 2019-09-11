# frozen_string_literal: true

module Bi
  class CompleteValueDept < BiLocalTimeRecord
    self.table_name = "COMPLETE_VALUE_DEPT"

    def self.all_month_names
      Bi::CompleteValueDept.order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.last_available_refresh_date(end_of_month)
      available_date = where("refresh_date <= ?", end_of_month).order(refresh_date: :desc).first&.date
      available_date = order(refresh_date: :desc).first.refresh_date if available_date.nil?
      available_date
    end
  end
end
