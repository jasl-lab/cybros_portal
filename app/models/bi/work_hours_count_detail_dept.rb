# frozen_string_literal: true

module Bi
  class WorkHoursCountDetailDept < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "WORK_HOURS_COUNT_DETAIL_DEPT"
  end
end
