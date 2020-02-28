# frozen_string_literal: true

module Edoc2
  class ProjectInfo < ApplicationRecord
    establish_connection :edoc2v5
    self.table_name = 'eform_thape_projectinfo'
    def readonly?
      true
    end

    def self.bussiness_type_name
      @bussiness_type_name ||= order(businesstypename: :asc)
        .select(:businesstypename).distinct.pluck(:businesstypename)
    end

    def self.project_category_name
      @project_category_name ||= order(projectcategoryname: :asc)
        .select(:projectcategoryname).distinct.pluck(:projectcategoryname)
    end

    def self.project_item_dept_name
      @project_item_dept_name ||= order(projectitemdeptname: :asc)
        .select(:projectitemdeptname).distinct.pluck(:projectitemdeptname)
    end

    def self.project_big_stage_name
      @project_big_stage_name ||= order(projectbigstagename: :asc)
        .select(:projectbigstagename).distinct.pluck(:projectbigstagename)
    end

    def self.milestones_name
      @milestones_name ||= order(milestonesname: :asc)
        .select(:milestonesname).distinct.pluck(:milestonesname)
    end
  end
end
