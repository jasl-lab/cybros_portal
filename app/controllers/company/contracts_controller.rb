# frozen_string_literal: true

class Company::ContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")

    @all_cities = Bi::NewMapInfo.all_cities
    @city = params[:city].presence || '上海市'
    @client = params[:client].presence


    @all_tracestates = Bi::NewMapInfo.all_tracestates
    @tracestate = params[:tracestate].presence || '跟踪中'

    map_infos = policy_scope(Bi::NewMapInfo).where(tracestate: @tracestate).where(company: @city)
    map_infos = map_infos.where("developercompanyname LIKE ?", "%#{@client}%") if @client.present?
    respond_to do |format|
      format.html
      format.json do
        render json: CompanyContractDatatable.new(params, map_infos: map_infos,
          city: @city, client: @client, tracestate: @tracestate)
      end
    end
  end

  protected

    def set_page_layout_data
      @_sidebar_name = "company"
    end
end
