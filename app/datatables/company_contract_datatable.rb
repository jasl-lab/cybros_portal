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
    @is_boutique = opts[:is_boutique]
    @query_text = opts[:query_text]
    super
  end

  def view_columns
    @view_columns ||= {
      project_no_and_name: { source: 'Bi::NewMapInfo.id', orderable: true },
      project_type_and_main_dept_name: { source: 'Bi::NewMapInfo.maindeptnamedet', orderable: true },
      total_sales_contract_amount: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    project_codes = records.collect(&:id)
    sa_contracts = Bi::SaContract.where(projectcode: project_codes).select(:projectcode, :amounttotal)
    sa_opportunities = Bi::SaProjectOpportunity.where(projectcode: project_codes).select(:projectcode, :contractamount)
    records.map do |r|
      project_items_array = r.project_items.collect { |c| [c.businesstypecnname, c.projectitemdeptname] }.uniq

      project_items = project_items_array.group_by(&:first).transform_values { |a| a.collect(&:second) }.to_a

      project_sa_contracts = sa_contracts.find_all { |c| c.projectcode.to_s == r.id.to_s }
      sa_contract_sum = if project_sa_contracts.present?
        project_sa_contracts.sum(&:amounttotal)
      else
        sa_opportunities.find { |o| o.projectcode.to_s == r.id.to_s }&.contractamount
      end
      project_type_and_main_dept_name = project_items.map do |p|
        '<strong>' + p[0] + '</strong>' + '<br />' + p[1].join('<br />')
      end.join('<br />')

      { project_no_and_name: "#{r.id}<br />#{link_to(r.marketinfoname, company_contract_path(id: r.id), remote: true)}<br />#{r.projectframename}".html_safe,
        project_type_and_main_dept_name: if project_type_and_main_dept_name.present?
                                           project_type_and_main_dept_name.html_safe
                                         else
                                           r.maindeptnamedet
                                         end,
        total_sales_contract_amount: sa_contract_sum.round(0) }
    end
  end

  def get_raw_records
    rr = @map_infos
    rr = rr.where.not(id: ['TX001', 'TH999999'])
    rr = rr.where('company LIKE ?', "%#{@city}%") if @city.present? && @city != '所有'
    rr = rr.where('developercompanyname LIKE ?', "%#{@client}%") if @client.present?
    rr = rr.where(tracestate: @tracestate) if @tracestate.present? && @tracestate != '所有'
    rr = rr.where('YEAR(CREATEDDATE) = ?', @createddate_year) unless @createddate_year == '所有'
    rr = rr.where('projecttype LIKE ?', "%#{@project_item_genre_name}%") if @project_item_genre_name.present?
    rr = rr.where('(isboutiqueproject IS NOT NULL AND isboutiqueproject > 0)') if @is_boutique
    if @query_text.present?
      rr = rr.where('developercompanyname LIKE ? OR marketinfoname LIKE ? OR projectframename like ? OR ID LIKE ?',
        "%#{@query_text}%", "%#{@query_text}%", "%#{@query_text}%", "%#{@query_text}%")
    end
    rr
  end
end
