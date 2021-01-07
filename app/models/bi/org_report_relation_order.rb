# frozen_string_literal: true

module Bi
  class OrgReportRelationOrder < BiLocalTimeRecord
    self.table_name = 'ORG_REPORT_RELATION_ORDER'

    def self.up_codes
      @up_codes ||= all.reduce({}) do |h, s|
        h[s.code] = s.upcode
        h
      end
    end
  end
end
