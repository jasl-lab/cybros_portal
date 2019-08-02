# frozen_string_literal: true

class Report::ProjectMilestoresController < Report::BaseController
  before_action :authenticate_user!, unless: -> { params[:in_iframe].present? }
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    @all_month_names = policy_scope(Bi::ShRefreshRate).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    end_of_month = Date.parse(@month_name).end_of_month
    target_date = policy_scope(Bi::ShRefreshRate).where("date <= ?", end_of_month).order(date: :desc).first.date

    @number_in_row = (params[:number_in_row] || 7).to_i
    @show_all_dept = params[:show_all_dept] == "true"

    Rails.logger.debug "Bi::ShRefreshRate target_date: #{target_date}"
    @person_count_by_department = policy_scope(Bi::ShRefreshRate).person_count_by_department(target_date)
    @person_by_department_in_sh = policy_scope(Bi::ShRefreshRate).person_by_department_in_sh(target_date, @show_all_dept)
    @departments = @person_by_department_in_sh.keys

    only_have_data_dept = (Bi::ShReportDeptOrder.all_deptcodes_in_order & @departments)
    @deptnames_in_order = only_have_data_dept.collect { |deptcode| Bi::ShReportDeptOrder.all_deptnames[deptcode] }

    @milestore_update_rate = only_have_data_dept.collect do |deptcode|
      rr = @person_by_department_in_sh[deptcode]
      if rr.present?
        rr_refresh = rr.collect { |d| d.refresh_count.to_i }.sum
        rr_total = rr.collect { |d| d.total_count.to_i }.sum
        ((rr_refresh / rr_total.to_f)*100).round(0)
      else
        0
      end
    end
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.project_milestore"),
      link: report_project_milestore_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
