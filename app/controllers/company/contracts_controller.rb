# frozen_string_literal: true

class Company::ContractsController < ApplicationController
  wechat_api
  before_action :authenticate_user!
  before_action :make_sure_wechat_user_login, only: %i[index ]
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    authorize Bi::NewMapInfo
    prepare_meta_tags title: t('.title')

    @city = params[:city].presence
    @client = params[:client].presence

    @all_tracestates = policy_scope(Bi::NewMapInfo).all_tracestates
    @tracestate = params[:tracestate].presence || '所有'
    @all_createddate_years = Bi::NewMapInfo.all_createddate_year
    @createddate_year = params[:createddate_year].presence || '所有'
    @project_item_genre_name = params[:project_item_genre_name].presence
    @is_boutique = params[:is_boutique] == 'on'
    @query_text = params[:query_text].presence

    map_infos = policy_scope(Bi::NewMapInfo)
    respond_to do |format|
      format.html
      format.json do
        render json: CompanyContractDatatable.new(params, map_infos: map_infos,
          city: @city,
          client: @client,
          tracestate: @tracestate,
          createddate_year: @createddate_year,
          project_item_genre_name: @project_item_genre_name,
          is_boutique: @is_boutique,
          query_text: @query_text,
          view_context: view_context)
      end
    end
  end

  def show
    @sas = Bi::SaContract.where(projectcode: params[:id])
    if @sas.blank?
      @project_opportunities = Bi::SaProjectOpportunity.where(projectcode: params[:id])
    end
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'company'
    end
end
