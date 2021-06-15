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

    def self.crmcode_from_query_names(client_name)
      all.where('clientsshort LIKE ?', "%#{client_name}%")
        .or(all.where('clientsname LIKE ?', "%#{client_name}%"))
        .pluck(:clients)
    end
  end
end
