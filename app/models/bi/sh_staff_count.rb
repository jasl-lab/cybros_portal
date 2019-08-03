# frozen_string_literal: true

module Bi
  class ShStaffCount < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "SH_STAFF_COUNT"

    def self.last_available_f_month
      order(f_month: :desc).first.f_month
    end
  end
end
