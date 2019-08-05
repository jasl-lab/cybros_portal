# frozen_string_literal: true

module Bi
  class WorkHoursCountOrg < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "WORK_HOURS_COUNT_ORG"

    def self.all_month_names
      Bi::WorkHoursCountOrg.pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
