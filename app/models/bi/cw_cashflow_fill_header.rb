# frozen_string_literal: true

module Bi
  class CwCashflowFillHeader < BiLocalTimeRecord
    self.table_name = 'CW_CASHFLOW_FILL'

    def self.all_dept_leaders
      @all_dept_leaders ||= Bi::CwCashflowFillHeader.all.select(:deptcode, :deptleader).reduce({}) do |h, d|
        h[d.deptcode] = d.deptleader
        h
      end
    end

    def self.all_dept_biz_type
      @all_dept_biz_type ||= Bi::CwCashflowFillHeader.all.select(:deptcode, :deptbusitype).reduce({}) do |h, d|
        h[d.deptcode] = d.deptbusitype
        h
      end
    end
  end
end
