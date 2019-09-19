# frozen_string_literal: true

class SubsidiaryNeedReceiveUnsignDetailDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def_delegator :@view, :hide_report_subsidiary_need_receive_unsign_detail_path
  def_delegator :@view, :un_hide_report_subsidiary_need_receive_unsign_detail_path

  def initialize(params, opts = {})
    @subsidiary_need_receive_unsign_details = opts[:subsidiary_need_receive_unsign_details]
    @end_of_date = opts[:end_of_date]
    @org_name = opts[:org_name]
    @unsign_receive_great_than = opts[:unsign_receive_great_than]
    @days_to_min_timecard_fill_great_than = opts[:days_to_min_timecard_fill_great_than]
    @show_hide = opts[:show_hide]
    super
  end

  def view_columns
    @view_columns ||= {
      org_name: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.orgname", cond: :like, searchable: true, orderable: true },
      dept_name: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.deptname", cond: :string_eq, searchable: true, orderable: true },
      project_manager_name: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.projectmanagername", cond: :string_eq, searchable: true, orderable: true },
      project_item_code_name: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.projectitemname", cond: :like, searchable: true, orderable: true },
      created_date: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.createddate", cond: :string_eq, searchable: true, orderable: true },
      unsign_receive: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.unsign_receive", orderable: true },
      f_date: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.fdate", orderable: true },
      min_timecard_fill: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.mintimecardfill", orderable: true },
      days_to_min_timecard_fill: { source: "Bi::SubCompanyNeedReceiveUnsignDetail.days_to_mintimecardfill", orderable: true },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    records.map do |r|
      { org_name: r.orgname,
        dept_name: r.deptname,
        project_manager_name: r.projectmanagername,
        project_item_code_name: "#{r.projectitemcode}<br />#{r.projectitemname}".html_safe,
        created_date: r.createddate.to_date,
        unsign_receive: tag.div((r.unsign_receive / 10000)&.round(0), class: "text-center"),
        f_date: r.fdate,
        min_timecard_fill: r.mintimecardfill,
        days_to_min_timecard_fill: tag.div(r.days_to_mintimecardfill, class: "text-center"),
        admin_action: if @show_hide
                        link_to(un_hide_icon, un_hide_report_subsidiary_need_receive_unsign_detail_path(project_item_code: r.projectitemcode), method: :patch)
                      else
                        link_to(hide_icon, hide_report_subsidiary_need_receive_unsign_detail_path(project_item_code: r.projectitemcode), method: :patch)
                      end
     }
    end
  end

  def get_raw_records
    rr = if @show_hide
      @subsidiary_need_receive_unsign_details.where("NEED_HIDE = 1")
    else
      @subsidiary_need_receive_unsign_details.where("NEED_HIDE != 1 OR NEED_HIDE IS NULL")
    end.where(date: @end_of_date)
    rr = rr.where(orgname: @org_name) if @org_name.present?
    rr = rr.where("unsign_receive > ?", @unsign_receive_great_than) unless @unsign_receive_great_than.zero?
    rr = rr.where("days_to_mintimecardfill > ?", @days_to_min_timecard_fill_great_than) unless @days_to_min_timecard_fill_great_than.zero?
    rr
  end
end
