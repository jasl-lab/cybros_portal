# frozen_string_literal: true

module Bi
  class StaffCount < BiLocalTimeRecord
    self.table_name = "STAFF_COUNT"

    def self.last_available_date(end_of_month)
      available_date = where("date <= ?", end_of_month).order(date: :desc).first&.date
      available_date = order(date: :desc).first.date if available_date.nil?
      available_date
    end

    def self.staff_per_short_company_name(end_of_month)
      available_date = last_available_date(end_of_month)
      where("date = ?", available_date).reduce({}) do |h, s|
        h[s.company] = s.count
        h
      end
    end
  end
end
