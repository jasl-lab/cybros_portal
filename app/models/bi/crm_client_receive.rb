# frozen_string_literal: true

module Bi
  class CrmClientReceive < BiLocalTimeRecord
    self.table_name = 'CRM_CLIENT_RECEIVE'

    def self.all_org_options
      @all_org_options ||= all.select(:orgcode_sum).distinct.collect do |s|
        [Bi::OrgShortName.company_short_names_by_orgcode.fetch(s.orgcode_sum, s.orgcode_sum), s.orgcode_sum]
      end
    end
  end
end
