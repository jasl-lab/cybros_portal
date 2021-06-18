# frozen_string_literal: true

class SubsidiaryNeedReceiveSignDetailDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def_delegator :@view, :hide_report_subsidiary_need_receive_sign_detail_path
  def_delegator :@view, :un_hide_report_subsidiary_need_receive_sign_detail_path
  def_delegator :@view, :total_receivables_drill_down_report_subsidiary_need_receive_sign_detail_path
  def_delegator :@view, :financial_receivables_drill_down_report_subsidiary_need_receive_sign_detail_path

  def initialize(params, opts = {})
    @subsidiary_need_receive_sign_details = opts[:subsidiary_need_receive_sign_details]
    @over_amount_great_than = opts[:over_amount_great_than]
    @accneedreceive_gt3_months_great_than = opts[:accneedreceive_gt3_months_great_than]
    @total_sign_receive_great_than = opts[:total_sign_receive_great_than]
    @end_of_date = opts[:end_of_date]
    @org_name = opts[:org_name]
    @dept_codes = opts[:dept_codes]
    @can_hide_item = opts[:can_hide_item]
    @show_hide = opts[:show_hide]
    super
  end

  def view_columns
    @view_columns ||= {
      org_dept_name: { source: 'Bi::SubCompanyNeedReceiveSignDetail.deptname', cond: :like, searchable: true, orderable: true },
      business_director_name: { source: 'Bi::SubCompanyNeedReceiveSignDetail.businessdirectorname', cond: :like, searchable: true, orderable: true },
      first_party_name: { source: 'Bi::SubCompanyNeedReceiveSignDetail.firstpartyname', cond: :like, searchable: true, orderable: true },
      sales_contract_code: { source: 'Bi::SubCompanyNeedReceiveSignDetail.salescontractcode', cond: :like, searchable: true, orderable: true },
      sales_contract_name: { source: 'Bi::SubCompanyNeedReceiveSignDetail.salescontractname', cond: :like, searchable: true, orderable: true },
      amount_total: { source: 'Bi::SubCompanyNeedReceiveSignDetail.amounttotal', cond: :gteq, searchable: true, orderable: true },
      collection_amount: { source: 'Bi::SubCompanyNeedReceiveSignDetail.collectionamount', cond: :gteq, searchable: true, orderable: true },
      contract_property_name: { source: 'Bi::SubCompanyNeedReceiveSignDetail.contractpropertyname', cond: :eq, searchable: true, orderable: true },
      contract_time:  { source: 'Bi::SubCompanyNeedReceiveSignDetail.contracttime', cond: :eq, searchable: true, orderable: true },
      acc_need_receive: { source: 'Bi::SubCompanyNeedReceiveSignDetail.accneedreceive', orderable: true },
      acc_need_receive_gt3_months: { source: 'Bi::SubCompanyNeedReceiveSignDetail.accneedreceive_gt3_months', orderable: true },
      sign_receive: { source: 'Bi::SubCompanyNeedReceiveSignDetail.sign_receive', orderable: true },
      over_amount: { source: 'Bi::SubCompanyNeedReceiveSignDetail.overamount', orderable: true },
      aging_amount_lt3_months: { source: 'Bi::SubCompanyNeedReceiveSignDetail.aging_amount_lt3_months', orderable: true },
      aging_amount_4to12_months: { source: 'Bi::SubCompanyNeedReceiveSignDetail.aging_amount_4to12_months', orderable: true },
      aging_amount_1to2_years: { source: 'Bi::SubCompanyNeedReceiveSignDetail.aging_amount_1to2_years', orderable: true },
      aging_amount_gt2_years: { source: 'Bi::SubCompanyNeedReceiveSignDetail.aging_amount_gt2_years', orderable: true },
      comment_on_sales_contract_code: { source: nil, searchable: false, orderable: false },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    sales_contract_codes = records.collect(&:salescontractcode)
    coc_histories = Bi::CommentOnSalesContractCode.order(record_month: :desc).where(sales_contract_code: sales_contract_codes)
    records.map do |r|
      coc_history = coc_histories.find_all { |c| c.sales_contract_code == r.salescontractcode }
      coc = if coc_history.present?
        coc_history.first
      else
        Bi::CommentOnSalesContractCode.new(sales_contract_code: r.salescontractcode, record_month: @end_of_date.end_of_month)
      end
      display_coc_history = coc_history.collect { |c| "#{c.record_month}: #{sanitize c.comment}" }
      { org_dept_name: "#{Bi::OrgShortName.company_short_names.fetch(r.orgname, r.orgname)}<br />#{r.deptname}".html_safe,
        business_director_name: r.businessdirectorname,
        first_party_name: r.firstpartyname,
        sales_contract_code: r.salescontractcode,
        sales_contract_name: r.salescontractname,
        amount_total: tag.div((r.amounttotal.to_f / 10000.0)&.round(0), class: 'text-center'),
        collection_amount: tag.div((r.collectionamount.to_f / 10000.0)&.round(0), class: 'text-center'),
        contract_property_name: r.contractpropertyname,
        contract_time: r.contracttime&.to_date,
        acc_need_receive: (link_to financial_receivables_drill_down_report_subsidiary_need_receive_sign_detail_path(end_of_date: @end_of_date.to_s(:db_short), contractcode: r.salescontractcode), remote: true do
                            tag.div((r.accneedreceive.to_f / 10000.0)&.round(0), class: 'text-center')
                          end),
        acc_need_receive_gt3_months: tag.div((r.accneedreceive_gt3_months.to_f / 10000.0)&.round(0), class: 'text-center'),
        sign_receive: (link_to total_receivables_drill_down_report_subsidiary_need_receive_sign_detail_path(end_of_date: @end_of_date.to_s(:db_short), contractcode: r.salescontractcode), remote: true do
                         tag.div(
                           ((r.accneedreceive.to_f > r.sign_receive.to_f ? r.accneedreceive.to_f : r.sign_receive.to_f) / 10000.0)&.round(0),
                         class: 'text-center')
                       end),
        over_amount: tag.div((r.overamount.to_f / 10000.0)&.round(0), class: 'text-center'),
        comment_on_sales_contract_code: if @can_hide_item
                                          render(partial: 'report/subsidiary_need_receive_sign_details/can_hide_comment', locals: { coc: coc, coc_history: display_coc_history })
                                        else
                                          render(partial: 'report/subsidiary_need_receive_sign_details/comment', locals: { coc: coc, coc_history: display_coc_history })
                                        end,
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
      @subsidiary_need_receive_sign_details.where('NEED_HIDE = 1')
    else
      @subsidiary_need_receive_sign_details.where('NEED_HIDE != 1 OR NEED_HIDE IS NULL')
    end.where(date: @end_of_date)
    rr = if @total_sign_receive_great_than.zero?
      rr
    else
      if @end_of_date <= Time.new(2021, 3, 1)
        rr.where('sign_receive + accneedreceive > ?', @total_sign_receive_great_than)
      else
        rr.where('sign_receive > ?', @total_sign_receive_great_than)
      end
    end

    rr = if !@over_amount_great_than.zero? && !@accneedreceive_gt3_months_great_than.zero?
      rr.where('overamount > ? OR accneedreceive_gt3_months > ?', @over_amount_great_than, @accneedreceive_gt3_months_great_than)
    elsif !@over_amount_great_than.zero?
      rr.where('overamount > ?', @over_amount_great_than)
    elsif !@accneedreceive_gt3_months_great_than.zero?
      rr.where('accneedreceive_gt3_months > ?', @accneedreceive_gt3_months_great_than)
    else
      rr
    end
    rr = rr.where(orgname: @org_name) if @org_name.present?
    rr = rr.where(deptcode: @dept_codes) if @dept_codes.present?
    rr
  end
end
