# frozen_string_literal: true

module Nc
  class Balance < NcLocalTimeRecord
    self.table_name = 'NC6337.V_BALANCE'

    def self.countc_at_month(month)
      countc_month = month.is_a?(String) ? month : month.to_s(:nc_month)
      @balance_countc ||= select(:yp, :countc)
        .order(yp: :desc)
        .collect { |p| [ p.yp, p.countc ] }
      @balance_countc.any? do |item|
        return item.second if countc_month >= item.first
      end
    end
  end
end
