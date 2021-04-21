# frozen_string_literal: true

module Bi
  class CrmClientOneYear < BiLocalTimeRecord
    self.table_name = 'CRM_CLIENT_ONEYEAR'

    def self.by_crmcode
      @by_crmcode ||= all.reduce({}) do |h, s|
        h[s.crmcode] = {
          avgamount: s.avgamount,
          avgarea: s.avgarea,
          avgsignday: s.avgsignday,
          contractalter: s.contractalter,
          landhrcost: s.landhrcost
        }
        h
      end
    end
  end
end
