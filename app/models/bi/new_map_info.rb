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
      return @_all_tracestates if @_all_tracestates.present?
      tracestates = Bi::NewMapInfo.order(tracestate: :asc).select(:tracestate).distinct.pluck(:tracestate)
      @_all_tracestates = tracestates.unshift(['跟踪状态', '所有'])
    end

    def self.all_tracestates_with_color_hint
      return @_all_tracestates_with_color_hint if @_all_tracestates_with_color_hint.present?
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
      @_all_tracestates_with_color_hint = tracestates.unshift(['跟踪状态','所有'])
    end

    def self.all_createddate_year
      return @_all_createddate_year if @_all_createddate_year.present?
      all_createddate_year = Bi::NewMapInfo.order('YEAR(CREATEDDATE)').select('YEAR(CREATEDDATE)').distinct.collect {|b| b['YEAR(CREATEDDATE)']}
      @_all_createddate_year = all_createddate_year.unshift(['跟踪时间','所有'])
    end
  end
end
