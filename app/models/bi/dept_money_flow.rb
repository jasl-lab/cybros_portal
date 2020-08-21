# frozen_string_literal: true

module Bi
  class DeptMoneyFlow < BiLocalTimeRecord
    self.table_name = 'OCDW.V_TH_DEPTMONEYFLOW'

    def self.all_month_names
      order(checkdate: :desc).select(:checkdate).distinct.pluck(:checkdate).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
