# frozen_string_literal: true

class Company::KmMapsController < ApplicationController
  before_action :authenticate_user!

  def show
    @biz_category = params[:biz_category]&.strip
    @prj_category = params[:prj_category]&.strip
    @client = params[:client]&.strip
    @province = params[:province]&.strip
    @city = params[:city]&.strip
    @company_name = params[:company_name]&.strip
    @department = params[:department]&.strip
    @service_stage = params[:service_stage]&.strip
    @project_progress = params[:project_progress]&.strip

    @available_departments = Edoc2::ProjectInfo.project_item_dept_name(@company_name)

    data = Edoc2::ProjectInfo.where.not(coordinate: nil)
      .where("iscontractcode='Y' AND businesstype IN('01', '02', '03', '04') AND NOT (businesstype='03' and projectsort in('工程','采购')) AND NOT (businesstype='04' and projectsort in('工程')) OR (projectbigstage='30' AND isboutiqueproject='是')")
    data = data.where(businesstypename: @biz_category) if @biz_category.present?
    data = data.where(projectsort: @prj_category) if @prj_category.present?
    data = data.where('clientname like ?', "%#{@client}%") if @client.present?
    data = data.where(provincename: @province) if @province.present?
    data = data.where(cityname: @city) if @city.present?
    data = data.where(projectitemcomname: @company_name) if @company_name.present?
    data = data.where(projectitemdeptname: @department) if @department.present?
    data = data.where(projectbigstagename: @service_stage) if @service_stage.present?
    data = data.where(milestonesname: @project_progress) if @project_progress.present?

    valid_map_infos = data.reject { |m| !m.coordinate.include?(',') }

    @valid_map_point = valid_map_infos.collect do |m|
      lat = m.coordinate.split(',')[1].to_f
      if lat >= 85.051128 || lat <= -85.051128
        Rails.logger.error "coordinate lat error: #{m.projectitemcode} #{m.projectitemname} #{m.coordinate}"
      end
      lng = m.coordinate.split(',')[0].to_f
      if lng >= 180 || lng <= -180
        Rails.logger.error "coordinate lng error: #{m.projectitemcode} #{m.projectitemname} #{m.coordinate}"
      end

      { code: m.projectitemcode,
        lat: lat,
        lng: lng }
    end
  end

  def show_model
    @project_info = Edoc2::ProjectInfo.find_by projectitemcode: params[:project_item_code]
    @project_items = Edoc2::ProjectInfo.where(projectcode: @project_info.projectcode)
    @new_map_info = Bi::NewMapInfo.find_by(id: @project_info.projectcode)
  end

  def fill_department
    company_name = params[:company_name]&.strip
    company_long_name = Bi::OrgShortName.company_long_names.fetch(company_name, company_name)
    @available_departments = Edoc2::ProjectInfo.project_item_dept_name(company_long_name)
  end

  def fill_category
    biz_category = params[:biz_category]&.strip
    @prj_categories = Edoc2::ProjectInfo.bussiness_type_project_category_maps[biz_category.to_sym]
  end

  def fill_city
    province = params[:province]&.strip
    @cities = Edoc2::ProjectInfo.city_options(province)
  end

  def fill_progress
    service_stage = params[:service_stage]&.strip
    @project_progress = Edoc2::ProjectInfo.project_big_stage_milestones_maps[service_stage.to_sym]
  end
end
