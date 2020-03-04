# frozen_string_literal: true

class Company::KmMapsController < ApplicationController
  before_action :authenticate_user!

  def show
    @biz_category = params[:biz_category]&.strip
    @prj_category = params[:prj_category]&.strip
    @company_name = params[:company_name]&.strip
    @department = params[:department]&.strip
    @service_stage = params[:service_stage]&.strip
    @project_progress = params[:project_progress]&.strip

    @available_departments = Edoc2::ProjectInfo.project_item_dept_name(@company_name)

    data = Edoc2::ProjectInfo
    data = data.where(businesstypename: @biz_category) if @biz_category.present?
    data = data.where(projectcategoryname: @prj_category) if @prj_category.present?
    data = data.where(projectitemcomname: @company_name) if @company_name.present?
    data = data.where(projectitemdeptname: @department) if @department.present?
    data = data.where(projectbigstagename: @service_stage) if @service_stage.present?
    data = data.where(milestonesname: @project_progress) if @project_progress.present?
    @valid_map_point = data
  end

  def fill_department
    @available_departments = Edoc2::ProjectInfo.project_item_dept_name(params[:company_name]&.strip)
  end
end
