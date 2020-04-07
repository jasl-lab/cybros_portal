# frozen_string_literal: true

module Bi
  class OrgShortName < BiLocalTimeRecord
    self.table_name = "ORG_SHORTNAME"

    def self.company_short_names
      @company_short_names ||= available_unit.reduce({}) do |h, s|
        h[s.name] = s.shortname
        h
      end
    end

    def self.company_long_names
      @company_long_names ||= available_unit.reduce({}) do |h, s|
        h[s.shortname] = s.name
        h
      end
    end

    def self.company_short_names_by_orgcode
      @company_short_names_by_orgcode ||= available_unit.reduce({}) do |h, s|
        h[s.code] = s.shortname
        h
      end
    end

    def self.company_long_names_by_orgcode
      @company_long_names_by_orgcode ||= available_unit.reduce({}) do |h, s|
        h[s.code] = s.name
        h
      end
    end

    def self.org_code_by_long_name
      @org_code_by_long_name ||= available_unit.reduce({}) do |h, s|
        h[s.name] = s.code
        h
      end
    end

    def self.org_code_by_short_name
      @org_code_by_short_name ||= available_unit.reduce({}) do |h, s|
        h[s.shortname] = s.code
        h
      end
    end

    def self.available_unit
      where(isbusinessunit: 'Y').where('PK_ORG IS NOT NULL')
    end
  end
end
