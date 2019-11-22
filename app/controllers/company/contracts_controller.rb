# frozen_string_literal: true

class Company::ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @hide_app_footer = true

    @all_cities = Bi::NewMapInfo.all_cities
    @city = params[:city].presence || '上海市'
    @client = params[:client].presence


    @all_tracestates = Bi::NewMapInfo.all_tracestates
    @tracestate = params[:tracestate].presence || '跟踪中'
    @query_text = params[:query_text].presence

    @map_infos = Bi::NewMapInfo.where(tracestate: @tracestate).where(company: @city).where.not(coordinate: nil)
    @map_infos = @map_infos.where("developercompanyname LIKE ?", "%#{@client}%") if @client.present?
    total_cos = @map_infos.collect(&:coordinate).reject {|c| !c.include?(',')}
    lat_total_cos = total_cos.collect { |c| c.split(',')[1].to_f }
    lng_total_cos = total_cos.collect { |c| c.split(',')[0].to_f }
    @min_lat = lat_total_cos.min
    @max_lat = lat_total_cos.max
    @min_lng = lng_total_cos.min
    @max_lng = lng_total_cos.max
  end

  protected

    def set_page_layout_data
      @_sidebar_name = "company"
    end
end
