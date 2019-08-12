# frozen_string_literal: true

module Bi
  class PkCodeName < BiLocalTimeRecord
    self.table_name = "PK_CODE_NAME"

    def self.mapping2deptcode
      @_mapping2deptcode ||= PkCodeName.all.reduce({}) do |h, s|
        h[s.deptcode] = s.deptname
        h
      end
    end

    def self.mapping2orgcode
      @_mapping2orgcode ||= PkCodeName.all.reduce({}) do |h, s|
        h[s.orgcode] = s.orgname
        h
      end
    end
  end
end
