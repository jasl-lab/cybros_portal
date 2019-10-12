# frozen_string_literal: true

class Report::ProjectMilestoresController < Report::BaseController
  before_action :authenticate_user!, unless: -> { params[:in_iframe].present? }, only: [:show]
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_drill_down_variables, only: %i[detail_drill_down], if: -> { request.format.js? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    @all_month_names = policy_scope(Bi::ShRefreshRate).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    end_of_month = Date.parse(@month_name).end_of_month
    @target_date = policy_scope(Bi::ShRefreshRate).where("date <= ?", end_of_month).order(date: :desc).first.date

    @number_in_row = (params[:number_in_row] || 7).to_i
    Rails.logger.debug "Bi::ShRefreshRate target_date: #{@target_date}"
    @company_short_names = policy_scope(Bi::ShRefreshRate).available_company_names(@target_date)
    @selected_org_code = params[:org_code]&.strip || current_user.user_company_orgcode

    @person_count_by_department = policy_scope(Bi::ShRefreshRate).person_count_by_department(@target_date)
    @person_by_department_in_sh = policy_scope(Bi::ShRefreshRate).person_by_department_in_sh(@target_date, @selected_org_code)
    @departments = @person_by_department_in_sh.keys

    @deptnames_in_order = @departments.collect { |deptcode| Bi::OrgReportDeptOrder.department_names(@target_date)[deptcode] }

    @milestore_update_rate = @departments.collect do |deptcode|
      rr = @person_by_department_in_sh[deptcode]
      if rr.present?
        rr_refresh = rr.collect { |d| d.refresh_count.to_i }.sum
        rr_total = rr.collect { |d| d.total_count.to_i }.sum
        ((rr_refresh / rr_total.to_f) * 100).round(0)
      else
        0
      end
    end
  end

  def detail_table_drill_down
    @all_month_names = policy_scope(Bi::ShRefreshRate).all_month_names
    @month_name = params[:month_name]&.strip
    end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @drill_down_subtitle = t(".subtitle")
    work_no = params[:work_no].strip
    scope_of_drill_down = Bi::ShRefreshRateDetail.where(projectpacode: work_no).where(date: beginning_of_month..end_of_month)
    project_item_codes = scope_of_drill_down.pluck(:projectitemcode).uniq
    @name = Bi::ShRefreshRateDetail.find_by(projectpacode: work_no).projectpaname
    @rows = project_item_codes.collect do |project_item_code|
      scope_of_drill_down.order(date: :desc).find_by(projectitemcode: project_item_code)
    end
    render
  end

  def detail_drill_down
    @rows = Bi::ShRefreshRateDetail
              .where(date: @last_available_date)
              .where(deptcode: @dept_code)
    render
  end

  def set_drill_down_variables
    @dept_name = params[:department_name].strip
    @drill_down_subtitle = t(".subtitle")
    @dept_code = Bi::ShReportDeptOrder.mapping2deptname.fetch(@dept_name, @dept_name)

    month_name = params[:month_name]&.strip
    end_of_month = Date.parse(month_name).end_of_month
    beginning_of_month = Date.parse(month_name).beginning_of_month

    @last_available_date = Bi::ShRefreshRateDetail.where(date: beginning_of_month..end_of_month).order(date: :desc).first.date
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.project_milestore", company: params[:company_name]&.strip || current_user.user_company_short_name),
        link: report_project_milestore_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
