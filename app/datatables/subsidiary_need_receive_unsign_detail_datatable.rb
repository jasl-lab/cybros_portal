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
      org_dept_name: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.deptname', cond: :string_eq, searchable: true, orderable: true },
      project_manager_name: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.projectmanagername', cond: :string_eq, searchable: true, orderable: true },
      project_item_code_name: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.projectitemname', cond: :like, searchable: true, orderable: true },
      created_date: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.createddate', cond: :string_eq, searchable: true, orderable: true },
      predict_amount: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.predictamount', orderable: true },
      unsign_receive: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.unsign_receive', orderable: true },
      f_date: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.fdate', orderable: true },
      min_timecard_fill: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.mintimecardfill', orderable: true },
      days_to_min_timecard_fill: { source: 'Bi::SubCompanyNeedReceiveUnsignDetail.days_to_mintimecardfill', orderable: true },
      comment_on_project_item_code: { source: nil, searchable: false, orderable: false },
      admin_action: { source: nil, searchable: false, orderable: false }
    }
  end

  def data
    project_item_codes = records.collect(&:projectitemcode)
    cop_histories = Bi::CommentOnProjectItemCode.order(record_month: :desc).where(project_item_code: project_item_codes)
    records.map do |r|
      cop_history = cop_histories.find_all { |c| c.project_item_code == r.projectitemcode }
      cop = if cop_history.present?
        cop_history.first
      else
        Bi::CommentOnProjectItemCode.new(project_item_code: r.projectitemcode, record_month: @end_of_date.end_of_month)
      end
      display_cop_history = cop_history.collect { |c| "#{c.record_month}: #{sanitize c.comment}" }
      { org_dept_name: "#{Bi::OrgShortName.company_short_names.fetch(r.orgname, r.orgname)}<br />#{r.deptname}".html_safe,
        project_manager_name: r.projectmanagername,
        project_item_code_name: "#{r.projectitemcode}<br />#{r.projectitemname}<br />#{r.projectstatus}".html_safe,
        created_date: r.createddate.to_date,
        predict_amount: tag.div((r.predictamount / 10000)&.round(0), class: 'text-center'),
        unsign_receive: tag.div((r.unsign_receive / 10000)&.round(0), class: 'text-center'),
        f_date: r.fdate,
        min_timecard_fill: "#{r.mintimecardfill}<br /><i>#{cop.comment}</i>".html_safe,
        days_to_min_timecard_fill: tag.div(r.days_to_mintimecardfill, class: 'text-center'),
        comment_on_project_item_code:
          render(partial: 'report/subsidiary_need_receive_unsign_details/comment', locals: { cop: cop, cop_history: display_cop_history }),
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
      @subsidiary_need_receive_unsign_details.where('NEED_HIDE = 1')
    else
      @subsidiary_need_receive_unsign_details.where('NEED_HIDE != 1 OR NEED_HIDE IS NULL')
    end.where(date: @end_of_date)
    rr = rr.where(orgname: @org_name) if @org_name.present?
    rr = rr.where('unsign_receive > ?', @unsign_receive_great_than) unless @unsign_receive_great_than.zero?
    rr = rr.where('days_to_mintimecardfill > ?', @days_to_min_timecard_fill_great_than) unless @days_to_min_timecard_fill_great_than.zero?
    rr
  end
end
