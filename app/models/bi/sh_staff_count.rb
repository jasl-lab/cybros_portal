# frozen_string_literal: true

module Bi
  class ShStaffCount < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "SH_STAFF_COUNT"

    def self.last_available_f_month
      order(f_month: :desc).first.f_month
    end

    def self.design_staff_per_deptname
      @_design_staff_per_deptname ||= all.reduce({}) do |h, d|
        h[d.deptname] = d.nowdesignnum
        h
      end
    end

    def self.design_staff_per_deptcode
      @_design_staff_per_deptcode ||= all.reduce({}) do |h, d|
        h[d.deptcode] = d.nowdesignnum
        h
      end
    end

    def self.other_staff_per_deptname
      @_other_staff_per_deptname ||= all.reduce({}) do |h, d|
        h[d.deptname] = d.nowothernum
        h
      end
    end

    def self.other_staff_per_deptcode
      @_other_staff_per_deptcode ||= all.reduce({}) do |h, d|
        h[d.deptcode] = d.nowothernum
        h
      end
    end
  end
end
