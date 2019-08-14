# frozen_string_literal: true

module Bi
  class StaffCount < BiLocalTimeRecord
    self.table_name = "STAFF_COUNT"

    def self.staff_per_short_company_name
      @staff_per_company ||= all.reduce({}) do |h, s|
        h[s.company] = s.count
        h
      end
    end

    def self.company_short_names
      @company_short_names ||= all.reduce({}) do |h, s|
        h[s.businessltdname] = s.company
        h
      end
    end

    def self.company_long_names
      @company_long_names ||= all.reduce({}) do |h, s|
        h[s.company] = s.businessltdname
        h
      end
    end
  end
end
