module Bi
  class StaffCount < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'STAFF_COUNT'

    def self.staff_per_company
      StaffCount.all.reduce({}) do |h, s|
        h[s.businessltdname] = s.count
        h
      end
    end
  end
end
