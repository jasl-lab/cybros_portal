# frozen_string_literal: true

module UltDb
  class Query < ApplicationRecord
    # No corresponding table in the DB.
    self.abstract_class = true
    establish_connection :ultdb2014r2
    def readonly?
      true
    end

    def self.contract_belong_company(clerk_code)
      sql = "SELECT CORPNAME FROM OPENQUERY(NC_TEST,'SELECT CORPNAME FROM NC6337.v_psndoc_ctrt WHERE LASTFLAG=''Y'' AND CLERKCODE=''#{clerk_code}'' ')"
      connection.select_value(sql)
    end
  end
end
