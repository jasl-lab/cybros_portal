# frozen_string_literal: true

module Bi
  class PkCodeName < BiLocalTimeRecord
    self.table_name = 'PK_CODE_NAME'

    def self.mapping2deptcode
      @_mapping2deptcode ||= PkCodeName.all.reduce({}) do |h, s|
        h[s.deptcode] = s.deptname
        h
      end
    end

    def self.mapping2deptname
      @_mapping2deptcode ||= PkCodeName.all.reduce({}) do |h, s|
        h[s.deptname] = s.deptcode
        h
      end
    end
  end
end
