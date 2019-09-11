# frozen_string_literal: true

class ContractSignDetailDatatable < ApplicationDatatable
  def_delegator :@view, :hide_report_contract_sign_detail_path
  def_delegator :@view, :un_hide_report_contract_sign_detail_path

  def initialize(params, opts = {})
    @contract_sign_detail_dates = opts[:contract_sign_detail_dates]
    @beginning_of_month = opts[:beginning_of_month]
    @end_of_month = opts[:end_of_month]
    @date_1_great_than = opts[:date_1_great_than]
    @show_hide = opts[:show_hide]
    super
  end

  def view_columns
    @view_columns ||= {
      org_name: { source: "Bi::ContractSignDetailDate.orgname", cond: :eq, searchable: true, orderable: true },
      dept_name: { source: "Bi::ContractSignDetailDate.deptname", cond: :eq, searchable: true, orderable: true },
      business_director_name: { source: "Bi::ContractSignDetailDate.businessdirectorname", cond: :eq, searchable: true, orderable: true },
      sales_contract_code_name: { source: "Bi::ContractSignDetailDate.salescontractname", cond: :like, searchable: true, orderable: true },
      first_party_name: { source: "Bi::ContractSignDetailDate.firstpartyname", cond: :like, searchable: true, orderable: true },
      amount_total: { source: "Bi::ContractSignDetailDate.amounttotal", orderable: true },
      date_1: { source: "Bi::ContractSignDetailDate.date1", orderable: true },
      date_2: { source: "Bi::ContractSignDetailDate.date2", orderable: true },
      contract_time: { source: "Bi::ContractSignDetailDate.contracttime", orderable: true },
      min_timecard_fill: { source: "Bi::ContractSignDetailDate.mintimecardfill", orderable: true },
      min_date_hrcost_amount: { source: "Bi::ContractSignDetailDate.mindatehrcostamount", orderable: true },
      project_type: { source: "Bi::ContractSignDetailDate.projecttype", cond: :eq, searchable: true, orderable: true },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |r|
      { org_name: Bi::StaffCount.company_short_names.fetch(r.orgname, r.orgname),
        dept_name: r.deptname,
        business_director_name: r.businessdirectorname,
        sales_contract_code_name: "#{r.salescontractcode}<br />#{r.salescontractname}".html_safe,
        first_party_name: r.firstpartyname,
        amount_total: r.amounttotal,
        date_1: r.date1,
        date_2: r.date2,
        contract_time: r.contracttime,
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
    end.where(contracttime: @beginning_of_month..@end_of_month)
    rr = rr.where("date1 > ?", @date_1_great_than) unless @date_1_great_than.zero?
    rr
  end
end
