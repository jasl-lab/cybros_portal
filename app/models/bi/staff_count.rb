# frozen_string_literal: true

module Bi
  class StaffCount < BiLocalTimeRecord
    self.table_name = "STAFF_COUNT"

    def self.last_available_date(end_of_month)
      available_date = where("f_month <= ?", end_of_month).order(f_month: :desc).first&.f_month
      available_date = order(f_month: :desc).first.f_month if available_date.nil?
      available_date
    end

    def self.staff_per_short_company_name(end_of_month)
      available_date = last_available_date(end_of_month)
      where("f_month = ?", available_date).reduce({}) do |h, s|
        h[Bi::OrgShortName.company_short_names_by_orgcode.fetch(s.orgcode, s.orgcode)] = s.avg_work
        h
      end
    end

    def self.staff_per_orgcode(end_of_month)
      available_date = last_available_date(end_of_month)
      where("f_month = ?", available_date).reduce({}) do |h, s|
        h[s.orgcode] = s.avg_work
        h
      end
    end
  end
end
