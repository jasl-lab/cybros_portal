# frozen_string_literal: true

module Bi
  class OrgOrder < BiLocalTimeRecord
    self.table_name = "ORG_ORDER"

    def self.all_company_names
      @all_company_names ||= select(:org_name)
        .where.not(org_shortname: nil)
        .order(org_order: :desc)
        .pluck(:org_name)
    end

    def self.all_company_shortnames_with_code
      @all_company_names_with_code ||= select(:org_shortname, :org_code)
        .where.not(org_shortname: nil)
        .where.not(org_code: nil)
        .order(org_order: :desc)
        .collect { |p| [ p.org_shortname, p.org_code ] }
    end
  end
end
