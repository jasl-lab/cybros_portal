# frozen_string_literal: true

module Bi
  class OrgOrder < BiLocalTimeRecord
    self.table_name = 'ORG_ORDER'

    def self.all_company_names
      @all_company_names ||= select(:org_name)
        .where.not(org_shortname: nil)
        .order(org_order: :desc)
        .pluck(:org_name)
    end
  end
end
