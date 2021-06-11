# frozen_string_literal: true

module Bi
  class DeptMoneyFlow < BiLocalTimeRecord
    self.table_name = 'OCDM.V_TH_DEPTMONEYFLOW'

    def self.all_month_names
      order(checkdate: :desc).select(:checkdate).distinct.pluck(:checkdate).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.last_available_date(end_of_month)
      available_date = where('checkdate <= ?', end_of_month).order(checkdate: :desc).first&.checkdate
      available_date = order(checkdate: :desc).first.checkdate if available_date.nil?
      available_date
    end
  end
end
