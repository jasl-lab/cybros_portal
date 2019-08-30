# frozen_string_literal: true

class ContractSignDetailDatatable < ApplicationDatatable
  def initialize(params, opts = {})
    @contract_sign_detail_dates = opts[:contract_sign_detail_dates]
    @view = opts[:view_context]
    super
  end

  def view_columns
    @view_columns ||= {
      project_code: { source: "Bi::ContractSignDetailDate.projectcode", cond: :eq, searchable: true, orderable: true },
      project_name: { source: "Bi::ContractSignDetailDate.projectname", cond: :like, searchable: true, orderable: true },
      sales_contract_code: { source: "Bi::ContractSignDetailDate.salescontractcode", cond: :like, searchable: true, orderable: true },
      sales_contract_name: { source: "Bi::ContractSignDetailDate.salescontractname", cond: :like, searchable: true, orderable: true }
    }
  end

  def data
    records.map do |r|
      { project_code: r.projectcode,
        project_name: r.projectname,
        business_director_name: r.businessdirectorname,
        sales_contract_code: r.salescontractcode,
        sales_contract_name: r.salescontractname,
        contract_status_name: r.contractstatusname,
        first_party_name: r.firstpartyname,
        contract_property_name: r.contractpropertyname,
        amount_total: r.amounttotal,
        date_1: r.date1,
        date_2: r.date2,
        contract_time: r.contracttime,
        min_time_card_fill: r.mintimecardfill,
        min_date_hr_cost_amount: r.mindatehrcostamount,
        org_code: r.orgcode,
        org_name: r.orgname,
        dept_code: r.deptcode,
        dept_name: r.deptname,
     }
    end
  end

  def get_raw_records
    @contract_sign_detail_dates
  end
end
