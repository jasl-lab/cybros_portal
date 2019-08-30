# frozen_string_literal: true

class ContractSignDetailDatatable < ApplicationDatatable
  def initialize(params, opts = {})
    @contract_sign_detail_dates = opts[:contract_sign_detail_dates]
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      org_name: { source: "Bi::ContractSignDetailDate.orgname", cond: :eq, searchable: true, orderable: true },
      dept_name: { source: "Bi::ContractSignDetailDate.deptname", cond: :eq, searchable: true, orderable: true },
      business_director_name: { source: "Bi::ContractSignDetailDate.businessdirectorname", cond: :eq, searchable: true, orderable: true },
      sales_contract_code: { source: "Bi::ContractSignDetailDate.salescontractcode", cond: :eq, searchable: true, orderable: true },
      sales_contract_name: { source: "Bi::ContractSignDetailDate.salescontractname", cond: :like, searchable: true, orderable: true },
      first_party_name: { source: "Bi::ContractSignDetailDate.firstpartyname", cond: :like, searchable: true, orderable: true },
      amount_total: { source: "Bi::ContractSignDetailDate.amounttotal", orderable: true },
      date_1: { source: "Bi::ContractSignDetailDate.date1", orderable: true },
      date_2: { source: "Bi::ContractSignDetailDate.date2", orderable: true },
      contract_time: { source: "Bi::ContractSignDetailDate.contracttime", orderable: true },
      min_timecard_fill: { source: "Bi::ContractSignDetailDate.mintimecardfill", orderable: true },
      min_date_hrcost_amount: { source: "Bi::ContractSignDetailDate.mindatehrcostamount", orderable: true },
      project_type: { source: "Bi::ContractSignDetailDate.projecttype", cond: :eq, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |r|
      { org_name: r.orgname,
        dept_name: r.deptname,
        business_director_name: r.businessdirectorname,
        sales_contract_code: r.salescontractcode,
        sales_contract_name: r.salescontractname,
        first_party_name: r.firstpartyname,
        amount_total: r.amounttotal,
        date_1: r.date1,
        date_2: r.date2,
        contract_time: r.contracttime,
        min_timecard_fill: r.mintimecardfill,
        min_date_hrcost_amount: r.mindatehrcostamount,
        project_type: r.projecttype,
     }
    end
  end

  def get_raw_records
    @contract_sign_detail_dates
  end
end
