# frozen_string_literal: true

class Company::KmMapsController < ApplicationController
  before_action :authenticate_user!

  def show
    @biz_category = params[:biz_category]&.strip
    @prj_category = params[:prj_category]&.strip
    @client = params[:client]&.strip
    @city = params[:city]&.strip
    @company_name = params[:company_name]&.strip
    @department = params[:department]&.strip
    @service_stage = params[:service_stage]&.strip
    @project_progress = params[:project_progress]&.strip

    @available_departments = Edoc2::ProjectInfo.project_item_dept_name(@company_name)

    data = Edoc2::ProjectInfo.where.not(coordinate: nil).where.not(projectitemcode: %w[TH20024401 TH20024501 TH20047001 TH20024601])
    data = data.where(businesstypename: @biz_category) if @biz_category.present?
    data = data.where('projectsort like ?', "%#{@prj_category}%") if @prj_category.present?
    data = data.where('clientname like ?', "%#{@client}%") if @client.present?
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
  end

  def fill_department
    @available_departments = Edoc2::ProjectInfo.project_item_dept_name(params[:company_name]&.strip)
  end

  def fill_category
    @biz_category = params[:biz_category]&.strip
    @prj_category = params[:prj_category]&.strip
  end

  def fill_progress
    @service_stage = params[:service_stage]&.strip
    @project_progress = params[:project_progress]&.strip
  end
end
