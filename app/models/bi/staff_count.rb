module Bi
  class StaffCount < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'STAFF_COUNT'

    def self.staff_per_company
      @staff_per_company ||= StaffCount.all.reduce({}) do |h, s|
        h[s.businessltdname] = s.count
        h
      end
    end

    def self.company_short_names
      @company_short_names ||= StaffCount.all.reduce({}) do |h, s|
        h[s.businessltdname] = s.company
        h
      end
    end
  end
end
