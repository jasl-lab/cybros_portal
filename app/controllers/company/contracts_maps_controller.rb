# frozen_string_literal: true

class Company::ContractsMapsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def show
    authorize Bi::NewMapInfo
    prepare_meta_tags title: t(".title")
    @hide_app_footer = true

    @city = params[:city].presence || '上海市'
    @client = params[:client].presence

    @all_tracestates = policy_scope(Bi::NewMapInfo).all_tracestates
    @tracestate = params[:tracestate].presence || '所有'
    @all_createddate_years = Bi::NewMapInfo.all_createddate_year
    @createddate_year = params[:createddate_year].presence || '所有'
    @query_text = params[:query_text].presence

    @need_locate_to_shanghai = @city == '上海市' && @tracestate == '所有' && @client.nil? && @query_text.nil?
    @need_locate_to_china = @city == '所有' && @tracestate == '所有' && @client.nil? && @query_text.nil?

    map_infos = policy_scope(Bi::NewMapInfo).where.not(coordinate: nil).includes(:rels, :project_items)
    map_infos = map_infos.where(tracestate: @tracestate) unless @tracestate == '所有'
    map_infos = map_infos.where('YEAR(CREATEDDATE) = ?', @createddate_year) unless @createddate_year == '所有'
    map_infos = map_infos.where("company LIKE ?", "%#{@city}%") unless @city == '所有'
    map_infos = map_infos.where("developercompanyname LIKE ?", "%#{@client}%") if @client.present?
    if @query_text.present?
      map_infos = map_infos
        .where("developercompanyname LIKE ? OR marketinfoname LIKE ? OR ID LIKE ?",
          "%#{@query_text}%", "%#{@query_text}%", "%#{@query_text}%")
    end

    @allow_download = begin
      authorize Bi::NewMapInfo, :allow_download?
      true
    rescue NotAuthorizedError
      false
    end

    @valid_map_infos = map_infos.reject {|m| !m.coordinate.include?(',')}

    total_cos = @valid_map_infos.collect(&:coordinate)
    @valid_map_point = @valid_map_infos.collect do |m|
      lat = m.coordinate.split(',')[1].to_f
      if lat >= 85.051128 || lat <= -85.051128
        Rails.logger.error "coordinate lat error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
      end
      lng = m.coordinate.split(',')[0].to_f
      if lng >= 180 || lng <= -180
        Rails.logger.error "coordinate lng error: #{m.id} #{m.marketinfoname} #{m.coordinate}"
      end
      project_items = m.project_items.order(:businesstypecnname, :projectitemdeptname)
        .group_by(&:businesstypecnname).transform_values { |a| a.collect(&:projectitemdeptname) }.to_a
      map_info = { title: m.marketinfoname,
                   lat: lat,
                   lng: lng,
                   developer_company: m.developercompanyname,
                   project_code: m.id,
                   trace_state: m.tracestate,
                   scale_area: m.scalearea,
                   province: m.province,
                   city: m.company,
                   big_stage: m.bigstage,
                   project_items: project_items }
      if @allow_download
        map_info = map_info.merge(contracts: (m.rels.collect { |r| { docname: r.docname, url: r.address } }))
      end
      map_info
    end

    lat_total_cos = total_cos.collect { |c| c.split(',')[1].to_f }
    lng_total_cos = total_cos.collect { |c| c.split(',')[0].to_f }
    @avg_lat = lat_total_cos.sum / lat_total_cos.size.to_f
    @avg_lng = lng_total_cos.sum / lng_total_cos.size.to_f
  end

  protected

    def set_page_layout_data
      @_sidebar_name = "company"
    end
end
