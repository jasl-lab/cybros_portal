# frozen_string_literal: true

module Ocdm
  class ThCwtbDay < OcdmLocalTimeRecord
    self.table_name = 'OCDM.TH_CWTB_DAY'

    def self.all_month_names
      Ocdm::ThCwtbDay.order(reportdate: :desc).select(:reportdate).distinct.pluck(:reportdate).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
