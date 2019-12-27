# frozen_string_literal: true

class CompanyContractDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def_delegator :@view, :company_contract_path

  def initialize(params, opts = {})
    @map_infos = opts[:map_infos]
    @city = opts[:city]
    @client = opts[:client]
    @tracestate = opts[:tracestate]
    @createddate_year = opts[:createddate_year]
    @project_item_genre_name = opts[:project_item_genre_name]
    @query_text = opts[:query_text]
    super
  end

  def view_columns
    @view_columns ||= {
      project_no_and_name: { source: "Bi::NewMapInfo.marketinfoname", orderable: true },
      project_type_and_main_dept_name: { source: "Bi::NewMapInfo.maindeptnamedet", orderable: true },
      scale_area: { source: "Bi::NewMapInfo.scalearea", orderable: true }
    }
  end

  def data
    records.map do |r|
      { project_no_and_name: "#{r.id}<br />#{link_to(r.marketinfoname, company_contract_path(id: r.id), remote: true)}<br />#{r.projectframename}".html_safe,
        project_type_and_main_dept_name: "#{r.projecttype}<br />#{r.maindeptnamedet}".html_safe,
        scale_area: r.scalearea }
    end
  end

  def get_raw_records
    rr = @map_infos
    rr = rr.where(company: @city) if @city.present? && @city != '所有'
    rr = rr.where("developercompanyname LIKE ?", "%#{@client}%") if @client.present?
    rr = rr.where(tracestate: @tracestate) if @tracestate.present? && @tracestate != '所有'
    rr = rr.where('YEAR(CREATEDDATE) = ?', @createddate_year) unless @createddate_year == '所有'
    rr = rr.where("projecttype LIKE ?", "%#{@project_item_genre_name}%") if @project_item_genre_name.present?
    if @query_text.present?
      rr = rr.where("developercompanyname LIKE ? OR marketinfoname LIKE ? OR ID LIKE ?",
        "%#{@query_text}%", "%#{@query_text}%", "%#{@query_text}%")
    end
    rr
  end
end
