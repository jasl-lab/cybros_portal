# frozen_string_literal: true

module Bi
  class OcdmThJttbYear < BiLocalTimeRecord
    self.table_name = 'OCDM.TH_JTTB_YEAR'

    def self.orgs_plan_contract_amounts(plan_month)
      where(ny: plan_month).select(:zgs, :qdhtbnjh1).reduce({}) do |h, t|
        h[t.zgs] = t.qdhtbnjh1
        h
      end
    end
  end
end
