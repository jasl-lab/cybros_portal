# frozen_string_literal: true

module Bi
  class CrmClientSum < BiLocalTimeRecord
    self.table_name = 'CRM_CLIENT_SUM'

    def self.all_month_names
      all.order(savedate: :desc).select(:savedate).distinct
        .pluck(:savedate).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
