# frozen_string_literal: true

module Bi
  class SubCompanyRealReceive < BiLocalTimeRecord
    self.table_name = 'SUB_COMPANY_REAL_RECEIVE'

    def self.all_month_names
      Bi::SubCompanyRealReceive.order(realdate: :desc).where("realdate >= '2019-09-01'")
        .pluck(:realdate).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
