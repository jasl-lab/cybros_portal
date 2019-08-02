# frozen_string_literal: true

module Bi
  class WorkHoursCount < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'WORK_HOURS_COUNT'
  end
end
