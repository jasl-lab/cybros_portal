# frozen_string_literal: true

class Report::ProjectMilestoresController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_drill_down_variables, only: %i[detail_drill_down], if: -> { request.format.js? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    prepare_meta_tags title: t('.title')
    @selected_org_code = params[:org_code]&.strip || current_user.can_access_org_codes.first || current_user.user_company_orgcode
    @all_month_names = policy_scope(Bi::ShRefreshRate).all_month_names(@selected_org_code)
    @month_name = params[:month_name]&.strip || @all_month_names.first
    if @month_name.blank?
      flash[:alert] = I18n.t('not_data_authorized')
      raise Pundit::NotAuthorizedError
    end
    end_of_month = Date.parse(@month_name).end_of_month
    @target_date = policy_scope(Bi::ShRefreshRate).where('date <= ?', end_of_month).order(date: :desc).first.date

    @number_in_row = (params[:number_in_row] || 7).to_i
    Rails.logger.debug "Bi::ShRefreshRate target_date: #{@target_date}"
    @company_short_names = policy_scope(Bi::ShRefreshRate).available_company_names(@target_date)

    @person_count_by_department = policy_scope(Bi::ShRefreshRate).person_count_by_department(@target_date)
    @person_by_department_in_sh = policy_scope(Bi::ShRefreshRate).person_by_department_in_sh(@target_date, @selected_org_code)
    @hr_staff_per_dept_codes = Hrdw::StfreinstateBi.hr_staff_per_dept_code_by_date(@selected_org_code, end_of_month)
    @department_codes = @hr_staff_per_dept_codes.keys

    @deptnames_in_order = @department_codes.collect { |deptcode| Bi::OrgReportDeptOrder.all_department_names[deptcode] }

    @milestore_update_rate = @department_codes.collect do |deptcode|
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
    @drill_down_subtitle = t('.subtitle')

    @month_name = params[:month_name]&.strip
    end_of_month = Date.parse(@month_name).end_of_month

    start_date = Date.today < end_of_month ? Date.today : end_of_month

    work_no = params[:work_no].strip

    scope_of_drill_down = nil

    loop do
      scope_of_drill_down = Bi::ShRefreshRateDetail.where(projectpacode: work_no).where(date: start_date).select(:projectitemcode)
      break if scope_of_drill_down.present?
      start_date -= 1.day
    end

    project_item_codes = scope_of_drill_down.pluck(:projectitemcode).uniq
    @rows = Bi::ShRefreshRateDetail.where(projectpacode: work_no)
      .where(date: start_date)
      .where(projectitemcode: project_item_codes)
      .order(date: :desc)
      .select(:projectitemcode, :projectitemname, :projectpaname, :projectprocess, :hours, :begindate)

    render
  end

  def detail_drill_down
    dept_code = params[:department_code].strip
    @rows = Bi::ShRefreshRateDetail
              .where(date: @last_available_date)
              .where(deptcode: dept_code)
    render
  end

  def set_drill_down_variables
    @dept_name = params[:department_name].strip
    @drill_down_subtitle = t('.subtitle')

    month_name = params[:month_name]&.strip
    end_of_month = Date.parse(month_name).end_of_month
    beginning_of_month = Date.parse(month_name).beginning_of_month

    @last_available_date = Bi::ShRefreshRateDetail.where(date: beginning_of_month..end_of_month).order(date: :desc).first.date
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.project_milestore', company: params[:company_name]&.strip || current_user.user_company_short_name),
        link: report_project_milestore_path }]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
