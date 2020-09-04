# frozen_string_literal: true

module Bi
  class ProvinceNewArea < BiLocalTimeRecord
    self.table_name = 'PROVINCE_NEW_AREA'

    def self.all_month_names
      all.order(date: :desc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
