# frozen_string_literal: true

class Company::ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")

    @all_cities = policy_scope(Bi::NewMapInfo).all_cities
    @city = params[:city].presence || '上海市'

    @all_tracestates = policy_scope(Bi::NewMapInfo).all_tracestates
    @tracestate = params[:tracestate].presence || '跟踪中'

    map_infos = policy_scope(Bi::NewMapInfo)
    map_infos = map_infos.where(tracestate: @tracestate) unless @tracestate == '所有'
    map_infos = map_infos.where(company: @city) unless @city == '所有'
    map_infos = map_infos.where("developercompanyname LIKE ?", "%#{@client}%") if @client.present?
    respond_to do |format|
      format.html
      format.json do
        render json: CompanyContractDatatable.new(params, map_infos: map_infos,
          city: @city, tracestate: @tracestate)
      end
    end
  end

  protected

    def set_page_layout_data
      @_sidebar_name = "company"
    end
end
