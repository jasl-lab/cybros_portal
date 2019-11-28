# frozen_string_literal: true

module Bi
  class NewMapInfo < BiLocalTimeRecord
    self.table_name = "V_TH_NEWMAPINFO"
    has_many :rels, class_name: "Bi::NewMapInfoRel", primary_key: :id, foreign_key: :projectcode

    def self.all_tracestates
      @_all_tracestates ||= ['所有'] + Bi::NewMapInfo.order(tracestate: :asc).select(:tracestate).distinct.pluck(:tracestate)
    end
  end
end
