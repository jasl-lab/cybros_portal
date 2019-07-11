module Bi
  class PkCodeName < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'PK_CODE_NAME'

    def self.company_long_names
      @company_long_names ||= PkCodeName.all.reduce({}) do |h, s|
        h[s.deptcode] = s.deptname
        h
      end
    end
  end
end
