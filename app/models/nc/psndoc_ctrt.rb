# frozen_string_literal: true

module Nc
  class PsndocCtrt < NcLocalTimeRecord
    self.table_name = 'NC6337.v_psndoc_ctrt'

    def self.contract_belong_company(clerk_code)
      sql = "SELECT CORPNAME FROM NC6337.v_psndoc_ctrt WHERE LASTFLAG='Y' AND CLERKCODE='#{clerk_code}'"
      connection.select_value(sql)
    end
  end
end
