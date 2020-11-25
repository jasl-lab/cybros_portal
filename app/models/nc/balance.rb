# frozen_string_literal: true

module Nc
  class Balance < NcLocalTimeRecord
    self.table_name = 'NC6337.V_BALANCE'

    def self.countc_at_month(month)
      @balance_countc ||= select(:yp, :countc)
        .order(yp: :desc)
        .collect { |p| [ p.yp, p.countc ] }
      @balance_countc.any? do |item|
        return item.second if month.to_s(:nc_month) >= item.first
      end
    end
  end
end
