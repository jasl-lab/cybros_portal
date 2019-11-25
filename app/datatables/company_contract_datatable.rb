# frozen_string_literal: true

class CompanyContractDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def initialize(params, opts = {})
    @map_infos = opts[:map_infos]
    @city = opts[:city]
    @tracestate = opts[:tracestate]
    super
  end

  def view_columns
    @view_columns ||= {
      project_no: { source: "Bi::NewMapInfo.id", cond: :string_eq, searchable: true, orderable: true },
      market_info_name: { source: "Bi::NewMapInfo.marketinfoname", cond: :like, searchable: true, orderable: true },
      developer_company_name: { source: "Bi::NewMapInfo.developercompanyname", cond: :like, searchable: true, orderable: true },
      project_type: { source: "Bi::NewMapInfo.projecttype", orderable: true },
      scale_area: { source: "Bi::NewMapInfo.scalearea", orderable: true },
      main_dept_name: { source: "Bi::NewMapInfo.maindeptnamedet", cond: :string_eq, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |r|
      { project_no: r.id,
        market_info_name: r.marketinfoname,
        developer_company_name: r.developercompanyname,
        project_type: r.projecttype,
        scale_area: r.scalearea,
        main_dept_name: r.maindeptnamedet }
    end
  end

  def get_raw_records
    rr = @map_infos
    rr = rr.where(company: @city) if @city.present?
    rr = rr.where(tracestate: @tracestate) if @tracestate.present?
    rr
  end
end
