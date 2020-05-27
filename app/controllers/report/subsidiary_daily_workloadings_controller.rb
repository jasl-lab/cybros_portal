class Report::SubsidiaryDailyWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  before_action :set_drill_down_params_and_title,
    only: %i[day_rate_drill_down planning_day_rate_drill_down building_day_rate_drill_down],
    if: -> { request.format.js? }

  def show
    authorize Bi::WorkHoursDayCountDept
    @begin_date = params[:begin_date]&.strip || Time.now.beginning_of_month
    @end_date = params[:end_date]&.strip || Time.now.end_of_day
    beginning_of_day = Date.parse(@begin_date).beginning_of_day unless @begin_date.is_a?(Time)
    end_of_day = Date.parse(@end_date).end_of_day unless @end_date.is_a?(Time)
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    @selected_company_code = params[:company_code].presence || current_user.user_company_orgcode
    @short_company_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(@selected_company_code, @selected_company_code)
    @company_short_names = policy_scope(Bi::WorkHoursDayCountDept).select(:orgcode)
      .distinct.where(date: beginning_of_day..end_of_day).collect do |r|
        [Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode), r.orgcode]
      end
    @job_company_or_department_names = []

    @is_non_construction = Report::BaseController::NON_CONSTRUCTION_COMPANYS.include?(@short_company_name)
    data = policy_scope(Bi::WorkHoursDayCountDept).where(date: beginning_of_day..end_of_day)
      .where(orgcode: @selected_company_code)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', end_of_day)
      .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', end_of_day)

    data = if @view_deptcode_sum
      data
        .select('WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum deptcode, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum')
        .order('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum')
    else
      data
        .select('WORK_HOURS_DAY_COUNT_DEPT.deptcode, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_DAY_COUNT_DEPT.deptcode')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode')
        .order('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode')
    end

    data = data.where(orgcode: user_company_orgcode) unless current_user.roles.pluck(:report_view_all).any? || current_user.admin?
    job_data = data.having('SUM(date_need) > 0')
    # exclude 建筑专项技术咨询所
    job_data = job_data.where.not(deptcode: %w[00010100801]) if @short_company_name == '上海天华'
    blue_print_data = data.having('SUM(blue_print_need) > 0')
    # exclude 公建一所 施工图综合所 建筑专项技术咨询所
    blue_print_data = blue_print_data.where.not(deptcode: %w[000101022 000101045 00010100801]) if @short_company_name == '上海天华'
    construction_data = data.having('SUM(construction_need) > 0')
    # exclude 建筑一A所 建筑二A所 建筑二C所 建筑三所 建筑三A所 建筑四所 建筑七所 公建七所
    construction_data = construction_data.where.not(deptcode: %w[000101055 000101143 000101122 000101013 000101125 000101061 000101017 000101075]) if @short_company_name == '上海天华'

    @job_company_or_department_codes = job_data.collect(&:deptcode)
    @job_company_or_department_names = @job_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    @blue_print_company_or_department_codes = blue_print_data.collect(&:deptcode)
    @blue_print_company_or_department_names = @blue_print_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    @construction_company_or_department_codes = construction_data.collect(&:deptcode)
    @construction_company_or_department_names = @construction_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end

    @day_rate = job_data.collect { |d| ((d.date_real / d.date_need.to_f) * 100).round(0) rescue 0 }
    @planning_day_rate = blue_print_data.collect { |d| ((d.blue_print_real / d.blue_print_need.to_f) * 100).round(0) rescue 0 }
    @building_day_rate = construction_data.collect { |d| ((d.construction_real / d.construction_need.to_f) * 100).round(0) rescue 0 }

  end

  def export
    authorize Bi::WorkHoursDayCountDept
  end

  def day_rate_drill_down
    @data =
      @data.select(:date, :date_need, :date_real, :fill_rate)
           .where.not(date_need: nil)
    render
  end

  def planning_day_rate_drill_down
    @data =
      @data.select(:date, :blue_print_need, :blue_print_real, :blue_print_rate)
           .where.not(blue_print_need: nil)
    render
  end

  def building_day_rate_drill_down
    @data =
      @data.select(:date, :construction_need, :construction_real, :construction_rate)
           .where.not(construction_need: nil)
    render
  end

  private
    def set_drill_down_params_and_title
      authorize Bi::WorkHoursDayCountDept
      short_company_code = params[:company_code]
      @company_name = Bi::OrgShortName.company_long_names_by_orgcode.fetch(short_company_code, short_company_code)
      department_name = params[:department_name]
      begin_date = Date.parse(params[:begin_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day

      belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: department_name)
      department_codes = if belong_deparments.exists?
        belong_deparments.pluck(:编号).reject { |dept_name| dept_name.include?('撤销') }
      else
        Bi::OrgReportDeptOrder.where(组织: @company_name, 部门: department_name).pluck(:编号)
      end

      @drill_down_subtitle = "#{begin_date.to_date} - #{end_date.to_date}"
      @data = policy_scope(Bi::WorkHoursDayCountDept).where(date: begin_date..end_date)
        .where(orgcode: short_company_code, deptcode: department_codes)
        .order(date: :desc)
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
        link: report_subsidiary_workloading_path },
      { text: t('layouts.sidebar.operation.subsidiary_daily_workloading'),
        link: report_subsidiary_daily_workloading_path }
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
