# frozen_string_literal: true

module Bi
  class CompleteValueDept < BiLocalTimeRecord
    self.table_name = "COMPLETE_VALUE_DEPT"

    def self.all_month_names
      Bi::CompleteValueDept.order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
