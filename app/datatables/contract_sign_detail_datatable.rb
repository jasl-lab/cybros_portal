# frozen_string_literal: true

class ContractSignDetailDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def_delegator :@view, :hide_report_contract_sign_detail_path
  def_delegator :@view, :un_hide_report_contract_sign_detail_path

  def initialize(params, opts = {})
    @contract_sign_detail_dates = opts[:contract_sign_detail_dates]
    @org_name = opts[:org_name]
    @beginning_of_month = opts[:beginning_of_month]
    @end_of_month = opts[:end_of_month]
    @date_1_great_than = opts[:date_1_great_than]
    @show_hide = opts[:show_hide]
    super
  end

  def view_columns
    @view_columns ||= {
      org_name: { source: "Bi::ContractSignDetailDate.orgname", searchable: false, orderable: true },
      dept_name: { source: "Bi::ContractSignDetailDate.deptname", cond: :string_eq, searchable: true, orderable: true },
      business_director_name: { source: "Bi::ContractSignDetailDate.businessdirectorname", cond: :string_eq, searchable: true, orderable: true },
      sales_contract_code_name: { source: "Bi::ContractSignDetailDate.salescontractname", cond: :like, searchable: true, orderable: true },
      first_party_name: { source: "Bi::ContractSignDetailDate.firstpartyname", cond: :like, searchable: true, orderable: true },
      amount_total: { source: "Bi::ContractSignDetailDate.amounttotal", cond: :gteq, orderable: true },
      date_1: { source: "Bi::ContractSignDetailDate.date1", orderable: true },
      date_2: { source: "Bi::ContractSignDetailDate.date2", orderable: true },
      contract_time: { source: "Bi::ContractSignDetailDate.filingtime", orderable: true },
      min_timecard_fill: { source: "Bi::ContractSignDetailDate.mintimecardfill", orderable: true },
      min_date_hrcost_amount: { source: "Bi::ContractSignDetailDate.mindatehrcostamount", orderable: true },
      project_type: { source: "Bi::ContractSignDetailDate.projecttype", cond: :string_eq, searchable: true, orderable: true },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |r|
      { org_name: Bi::OrgShortName.company_short_names.fetch(r.orgname, r.orgname),
        dept_name: r.deptname,
        business_director_name: r.businessdirectorname,
        sales_contract_code_name: "#{r.salescontractcode}<br />#{r.salescontractname}".html_safe,
        first_party_name: r.firstpartyname,
        amount_total: tag.div(r.amounttotal, class: "text-center"),
        date_1: tag.div(r.date1, class: "text-center"),
        date_2: tag.div(r.date2, class: "text-center"),
        contract_time: r.filingtime,
        min_timecard_fill: r.mintimecardfill,
        min_date_hrcost_amount: r.mindatehrcostamount,
        project_type: r.projecttype,
        admin_action: if @show_hide
                        link_to(un_hide_icon, un_hide_report_contract_sign_detail_path(contract_code: r.salescontractcode), method: :patch)
                      else
                        link_to(hide_icon, hide_report_contract_sign_detail_path(contract_code: r.salescontractcode), method: :patch)
                      end
     }
    end
  end

  def get_raw_records
    rr = if @show_hide
      @contract_sign_detail_dates.where("NEED_HIDE = 1")
    else
      @contract_sign_detail_dates.where("NEED_HIDE != 1 OR NEED_HIDE IS NULL")
    end.where(filingtime: @beginning_of_month..@end_of_month)
    rr = rr.where("date1 > ?", @date_1_great_than) unless @date_1_great_than.zero?
    rr = rr.where(orgname: @org_name) if @org_name.present?
    rr
  end
end
