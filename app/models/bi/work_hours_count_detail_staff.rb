module Bi
  class WorkHoursCountDetailStaff < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'WORK_HOURS_COUNT_DETAIL_STAFF'
  end
end
