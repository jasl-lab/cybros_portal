# frozen_string_literal: true

class SubsidiaryNeedReceiveSignDetailDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def_delegator :@view, :hide_report_subsidiary_need_receive_sign_detail_path
  def_delegator :@view, :un_hide_report_subsidiary_need_receive_sign_detail_path

  def initialize(params, opts = {})
    @subsidiary_need_receive_sign_details = opts[:subsidiary_need_receive_sign_details]
    @over_amount_great_than = opts[:over_amount_great_than]
    @sign_receive_great_than = opts[:sign_receive_great_than]
    @end_of_date = opts[:end_of_date]
    @org_name = opts[:org_name]
    @show_hide = opts[:show_hide]
    super
  end

  def view_columns
    @view_columns ||= {
      org_name: { source: "Bi::SubCompanyNeedReceiveSignDetail.orgname", searchable: false, orderable: true },
      dept_name: { source: "Bi::SubCompanyNeedReceiveSignDetail.deptname", cond: :string_eq, searchable: true, orderable: true },
      business_director_name: { source: "Bi::SubCompanyNeedReceiveSignDetail.businessdirectorname", cond: :string_eq, searchable: true, orderable: true },
      first_party_name: { source: "Bi::SubCompanyNeedReceiveSignDetail.firstpartyname", cond: :like, searchable: true, orderable: true },
      sales_contract_code_name: { source: "Bi::SubCompanyNeedReceiveSignDetail.salescontractname", cond: :like, searchable: true, orderable: true },
      amount_total: { source: "Bi::SubCompanyNeedReceiveSignDetail.amounttotal", cond: :gteq, searchable: true, orderable: true },
      contract_property_name: { source: "Bi::SubCompanyNeedReceiveSignDetail.contractpropertyname", orderable: true },
      contract_time: { source: "Bi::SubCompanyNeedReceiveSignDetail.contracttime", orderable: true },
      sign_receive: { source: "Bi::SubCompanyNeedReceiveSignDetail.sign_receive", orderable: true },
      acc_need_receive: { source: 'Bi::SubCompanyNeedReceiveSignDetail.accneedreceive', orderable: true },
      over_amount: { source: "Bi::SubCompanyNeedReceiveSignDetail.overamount", orderable: true },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |r|
      { org_name: Bi::OrgShortName.company_short_names.fetch(r.orgname, r.orgname),
        dept_name: r.deptname,
        business_director_name: r.businessdirectorname,
        first_party_name: r.firstpartyname,
        sales_contract_code_name:  "#{r.salescontractcode}<br />#{r.salescontractname}".html_safe,
        amount_total: tag.div((r.amounttotal.to_f / 10000.0)&.round(0), class: "text-center"),
        contract_property_name: r.contractpropertyname,
        contract_time: r.contracttime.to_date,
        sign_receive: tag.div((r.sign_receive.to_f / 10000.0)&.round(0), class: "text-center"),
        acc_need_receive: tag.div((r.accneedreceive.to_f / 10000.0)&.round(0), class: 'text-center'),
        over_amount: tag.div((r.overamount.to_f / 10000.0)&.round(0), class: "text-center"),
        admin_action: if @show_hide
                        link_to(un_hide_icon, un_hide_report_subsidiary_need_receive_sign_detail_path(sales_contract_code: r.salescontractcode), method: :patch)
                      else
                        link_to(hide_icon, hide_report_subsidiary_need_receive_sign_detail_path(sales_contract_code: r.salescontractcode), method: :patch)
                      end
     }
    end
  end

  def get_raw_records
    rr = if @show_hide
      @subsidiary_need_receive_sign_details.where("NEED_HIDE = 1")
    else
      @subsidiary_need_receive_sign_details.where("NEED_HIDE != 1 OR NEED_HIDE IS NULL")
    end.where(date: @end_of_date)
    rr = rr.where("sign_receive > ?", @sign_receive_great_than) unless @sign_receive_great_than.zero?
    rr = rr.where("overamount > ?", @over_amount_great_than) unless @over_amount_great_than.zero?
    rr = rr.where(orgname: @org_name) if @org_name.present?
    rr
  end
end
