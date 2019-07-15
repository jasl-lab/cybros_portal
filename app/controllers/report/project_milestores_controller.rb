class Report::ProjectMilestoresController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @number_in_row = (params[:number_in_row] || 7).to_i

    @all_deptnames_in_order = Bi::ShReportDeptOrder.all_deptnames_in_order

    @person_count_by_department = Bi::ShRefreshRate.person_count_by_department
    @person_by_department_in_sh = Bi::ShRefreshRate.person_by_department_in_sh
    @departments = @person_by_department_in_sh.keys

    @milestore_update_rate = Bi::ShReportDeptOrder.all_deptcodes_in_order.collect do |deptcode|
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
