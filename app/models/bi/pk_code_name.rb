# frozen_string_literal: true

module Bi
  class PkCodeName < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "PK_CODE_NAME"

    def self.mapping2deptcode
      @_mapping2deptcode ||= PkCodeName.all.reduce({}) do |h, s|
        h[s.deptcode] = s.deptname
        h
      end
    end
  end
end
