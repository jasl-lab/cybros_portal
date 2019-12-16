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
    @query_text = opts[:query_text]
    super
  end

  def view_columns
    @view_columns ||= {
      project_no: { source: "Bi::NewMapInfo.id", cond: :like, searchable: true, orderable: true },
      market_info_name: { source: "Bi::NewMapInfo.marketinfoname", cond: :like, searchable: true, orderable: true },
      project_type_scale_area: { source: "Bi::NewMapInfo.scalearea", orderable: true },
      main_dept_name: { source: "Bi::NewMapInfo.maindeptnamedet", cond: :string_eq, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |r|
      { project_no: "#{r.id}<br />#{link_to('合同查看', company_contract_path(id: r.id), remote: true)}".html_safe,
        market_info_name: r.marketinfoname,
        project_type_scale_area: "#{r.projecttype}<br />#{r.scalearea}".html_safe,
        main_dept_name: r.maindeptnamedet }
    end
  end

  def get_raw_records
    rr = @map_infos
    rr = rr.where(company: @city) if @city.present? && @city != '所有'
    rr = rr.where("developercompanyname LIKE ?", "%#{@client}%") if @client.present?
    rr = rr.where(tracestate: @tracestate) if @tracestate.present? && @tracestate != '所有'
    rr = rr.where('YEAR(CREATEDDATE) = ?', @createddate_year) unless @createddate_year == '所有'
    if @query_text.present?
      rr = rr.where("developercompanyname LIKE ? OR marketinfoname LIKE ? OR ID LIKE ?",
        "%#{@query_text}%", "%#{@query_text}%", "%#{@query_text}%")
    end
    rr
  end
end
