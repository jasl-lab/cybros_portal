# frozen_string_literal: true

module Bi
  class NewMapInfo < BiLocalTimeRecord
    self.table_name = "V_TH_NEWMAPINFO"
    has_many :rels, class_name: "Bi::NewMapInfoRel", primary_key: :id, foreign_key: :projectcode
    has_many :project_items, class_name: "Bi::GczProjectItem", primary_key: :id, foreign_key: :projectcode

    def self.all_cities
      @_all_cities ||= ['所有'] + Bi::NewMapInfo.order(company: :asc).select(:company).distinct.pluck(:company)
    end

    def self.all_tracestates
      @_all_tracestates ||= ['所有'] + Bi::NewMapInfo.order(tracestate: :asc).select(:tracestate).distinct.pluck(:tracestate)
    end

    def self.all_tracestates_with_color_hint
      tracestates = Bi::NewMapInfo.order(tracestate: :asc).select(:tracestate).distinct.pluck(:tracestate)
      tracestates = tracestates.collect do |t|
        case t
        when '跟踪中'
          ["#{t}(红色)", t]
        when '跟踪失败'
          ["#{t}(灰色)", t]
        when '跟踪成功'
          ["#{t}(蓝色)", t]
        end
      end
      @_all_tracestates ||= ['所有'] + tracestates
    end

    def self.all_createddate_year
      @_all_createddate_year ||= ['所有'] + Bi::NewMapInfo.order('YEAR(CREATEDDATE)').select('YEAR(CREATEDDATE)').distinct.collect {|b| b['YEAR(CREATEDDATE)']}
    end
  end
end
