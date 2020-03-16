# frozen_string_literal: true

class Report::SubsidiaryWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_drill_down_params_and_title,
    only: %i[day_rate_drill_down planning_day_rate_drill_down building_day_rate_drill_down],
    if: -> { request.format.js? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }
  after_action :verify_authorized

  def show
    authorize Bi::WorkHoursCountOrg
    current_user_companies = current_user.user_company_names

    @all_month_names = Bi::WorkHoursCountOrg.all_month_names
    @begin_month_name = params[:begin_month_name]&.strip || @all_month_names.first
    @end_month_name = params[:end_month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@begin_month_name).beginning_of_month
    end_of_month = Date.parse(@end_month_name).end_of_month

    @short_company_name = params[:company_name].presence || current_user.user_company_short_name
    @company_short_names = policy_scope(Bi::WorkHoursCountDetailDept).select(:orgname)
      .distinct.where(date: beginning_of_month..end_of_month).collect { |r| Bi::OrgShortName.company_short_names.fetch(r.orgname, r.orgname) }
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    @selected_company_name = params[:company_name]&.strip

    @company_name = Bi::OrgShortName.company_long_names.fetch(@short_company_name, @short_company_name)
    data = policy_scope(Bi::WorkHoursCountDetailDept).where(date: beginning_of_month..end_of_month)
      .where(orgname: @company_name)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', end_of_month)
      .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', end_of_month)

    data = if @view_deptcode_sum
      data
        .select('WORK_HOURS_COUNT_DETAIL_DEPT.deptcode_sum deptcode, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_COUNT_DETAIL_DEPT.deptcode_sum')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_COUNT_DETAIL_DEPT.deptcode_sum')
        .order('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_COUNT_DETAIL_DEPT.deptcode_sum')
    else
      data
        .select('WORK_HOURS_COUNT_DETAIL_DEPT.deptcode, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_COUNT_DETAIL_DEPT.deptcode')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_COUNT_DETAIL_DEPT.deptcode')
        .order('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_COUNT_DETAIL_DEPT.deptcode')
    end

    data = data.where(orgname: current_user_companies) unless current_user.roles.pluck(:report_view_all).any? || current_user.admin?
    job_data = data.having('SUM(date_real) > 0')
    job_data = job_data.where.not(deptname: %w[建筑专项技术咨询所]) if @short_company_name == '上海天华'
    blue_print_data = data.having('SUM(blue_print_real)')
    blue_print_data = blue_print_data.where.not(deptname: %w[公建一所 施工图综合所 建筑专项技术咨询所]) if @short_company_name == '上海天华'
    construction_data = data.having('SUM(construction_real) > 0')
    construction_data = construction_data.where.not(deptname: %w[建筑一A所 建筑二A所 建筑二C所 建筑三所 建筑三A所 建筑四所 建筑七所 公建七所]) if @short_company_name == '上海天华'

    job_company_or_department_codes = job_data.collect(&:deptcode)
    @job_company_or_department_names = job_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    blue_print_company_or_department_codes = blue_print_data.collect(&:deptcode)
    @blue_print_company_or_department_names = blue_print_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    construction_company_or_department_codes = construction_data.collect(&:deptcode)
    @construction_company_or_department_names = construction_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    @second_level_drill = true

    @day_rate = job_data.collect { |d| ((d.date_real / d.date_need.to_f) * 100).round(0) rescue 0 }
    @day_rate_ref = params[:day_rate_ref] || 95

    @planning_day_rate = blue_print_data.collect { |d| ((d.blue_print_real / d.blue_print_need.to_f) * 100).round(0) rescue 0 }
    @planning_day_rate_ref = params[:planning_day_rate_ref] || 95

    @building_day_rate = construction_data.collect { |d| ((d.construction_real / d.construction_need.to_f) * 100).round(0) rescue 0 }
    @building_day_rate_ref = params[:building_day_rate_ref] || 80

    @current_user_companies_short_names = current_user_companies.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
  end

  def export
    authorize Bi::WorkHoursCountOrg

    respond_to do |format|
      format.csv do
        render_csv_header 'Subsidiary Workloadings'
        csv_res = CSV.generate do |csv|
          csv << ['ID', '日期', '公司', '天数需填', '天数实填', '方案需填', '方案实填', '施工图需填', '施工图实填']
          policy_scope(Bi::WorkHoursCountOrg).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.date
            values << s.orgname
            values << s.date_need
            values << s.date_real
            values << s.blue_print_need
            values << s.blue_print_real
            values << s.construction_need
            values << s.construction_real
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end

  def day_rate_drill_down
    @data =
      @data.select(:user_name, :deptname, :date, :date_need, :date_real, :fill_rate)
           .where.not(date_need: nil)
    render
  end

  def planning_day_rate_drill_down
    @data =
      @data.select(:user_name, :deptname, :date, :blue_print_need, :blue_print_real, :blue_print_rate)
           .where.not(blue_print_need: nil)
    render
  end

  def building_day_rate_drill_down
    @data =
      @data.select(:user_name, :deptname, :date, :construction_need, :construction_real, :construction_rate)
           .where.not(construction_need: nil)
    render
  end

  private

    def set_drill_down_params_and_title
      authorize Bi::WorkHoursCountDetailStaff
      short_company_name = params[:company_name]
      @company_name = Bi::OrgShortName.company_long_names.fetch(short_company_name, short_company_name)
      @department_name = params[:department_name]
      begin_month = Date.parse(params[:begin_month_name]).beginning_of_month
      end_month = Date.parse(params[:end_month_name]).end_of_month

      @day_rate_ref = params[:day_rate_ref].to_i
      @planning_day_rate_ref = params[:planning_day_rate_ref].to_i
      @building_day_rate_ref = params[:building_day_rate_ref].to_i

      belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @department_name)
      if belong_deparments.exists?
        @department_name = belong_deparments.pluck(:部门).reject { |dept_name| dept_name.include?('撤销') }
      end

      @drill_down_subtitle = "#{begin_month} - #{end_month}"
      @data = policy_scope(Bi::WorkHoursCountDetailStaff).where(date: begin_month..end_month)
        .where(orgname: @company_name, deptname: @department_name)
        .order(date: :desc, user_name: :asc)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_workloading'),
        link: report_group_workloading_path(view_orgcode_sum: true) },
      { text: t('layouts.sidebar.operation.subsidiary_workloading'),
        link: report_subsidiary_workloading_path }]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
