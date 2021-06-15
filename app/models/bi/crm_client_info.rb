# frozen_string_literal: true

module Bi
  class CrmClientInfo < BiLocalTimeRecord
    self.table_name = 'OCDW.CRM_CLIENTINFO'

    def self.crm_short_names
      @crm_short_names ||= all.select(:clients, :clientsshort, :clientsname).reduce({}) do |h, s|
        h[s.clients] = s.clientsshort || s.clientsname
        h
      end
    end
  end
end
