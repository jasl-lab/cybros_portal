# frozen_string_literal: true

module Edoc2
  class ProjectInfo < ApplicationRecord
    establish_connection :edoc2v5
    self.table_name = 'eform_thape_projectinfo'
    def readonly?
      true
    end

    def self.bussiness_type_project_category_maps
      {
        '建筑': %w[住宅 公建 工业],
        '室内': %w[住宅 商办 酒店 硬装 软装],
        '规划': %w[法定规划 非法定规划],
        '景观': %w[住宅 公建 市政]
      }
    end

    def self.project_big_stage_milestones_maps
      {
        '前端': %w[概念方案 方案报批通过 立面控制手册 建筑扩初 竣工验收],
        '后端': %w[扩初完成 方案配合 审图通过 结构封顶 竣工验收]
      }
    end

    def self.province_options
      @province_options ||= order('provincename asc')
        .select(:provincename).distinct.pluck(:provincename)
    end

    def self.city_options(province = nil)
      if province.blank?
        []
      else
        where(provincename: province).order('cityname asc')
          .select(:cityname).distinct.pluck(:cityname)
      end
    end

    def self.project_item_company_name
      @project_item_company_name ||= order('projectitemcomname asc')
        .select(:projectitemcomname).distinct.pluck(:projectitemcomname).map do |long_name|
          Bi::OrgShortName.company_short_names.fetch(long_name, long_name)
        end
    end

    def self.project_item_dept_name(company_name = nil)
      if company_name.blank?
        []
      else
        where(projectitemcomname: company_name).order('projectitemdeptname asc')
        .select(:projectitemdeptname).distinct.pluck(:projectitemdeptname)
      end
    end

    def self.milestones_name
      @milestones_name ||= order(milestonesname: :asc)
        .select(:milestonesname).distinct.pluck(:milestonesname)
    end
  end
end
