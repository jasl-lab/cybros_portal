# frozen_string_literal: true

module Bi
  class OcdmThJttbYear < BiLocalTimeRecord
    self.table_name = 'OCDM.TH_JTTB_YEAR'

    def self.orgs_plan_contract_amounts(plan_month)
      last_month_data = nil

      loop do
        last_month_data = where(ny: plan_month.to_s(:short_month)).select(:zgs, :qdhtbnjh1)
        break if last_month_data.present?
        plan_month -= 1.month
      end

      last_month_data.reduce({}) do |h, t|
        h[t.zgs] = t.qdhtbnjh1
        h
      end
    end
  end
end
