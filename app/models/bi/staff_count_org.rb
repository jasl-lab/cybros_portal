# frozen_string_literal: true

module Bi
  class StaffCountOrg < BiLocalTimeRecord
    self.table_name = "STAFF_COUNT_ORG"

    def self.all_month_names
      Bi::StaffCountOrg.order("`日期` asc").pluck(:日期).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
