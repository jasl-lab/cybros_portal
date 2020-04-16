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
        '建筑': %w[居住建筑 商业建筑 办公建筑 酒店建筑 教育建筑 文体建筑 医养建筑 交通建筑 工业建筑],
        '室内': %w[住宅 公建],
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

    def self.city_options
      @city_options ||= order(provincename: :asc, cityname: :asc)
        .select(:provincename, :cityname).distinct.pluck(:provincename, :cityname)
        .collect { |a| ["#{a[0]}#{a[1]}", a[1]] }
    end

    def self.project_item_company_name
      @project_item_company_name ||= order(projectitemcomname: :asc)
        .select(:projectitemcomname).distinct.pluck(:projectitemcomname).map do |long_name|
          Bi::OrgShortName.company_short_names.fetch(long_name, long_name)
        end
    end

    def self.project_item_dept_name(company_name = nil)
      @project_item_dept_name ||= order(projectitemdeptname: :asc)
        .select(:projectitemdeptname).distinct.pluck(:projectitemdeptname)

      if company_name.blank?
        @project_item_dept_name
      else
        where(projectitemcomname: company_name).order(projectitemdeptname: :asc)
        .select(:projectitemdeptname).distinct.pluck(:projectitemdeptname)
      end
    end

    def self.milestones_name
      @milestones_name ||= order(milestonesname: :asc)
        .select(:milestonesname).distinct.pluck(:milestonesname)
    end
  end
end
