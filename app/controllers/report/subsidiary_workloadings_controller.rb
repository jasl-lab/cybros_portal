# frozen_string_literal: true

class Report::SubsidiaryWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  before_action :set_drill_down_params_and_title, only: %i[day_rate_drill_down planning_day_rate_drill_down building_day_rate_drill_down],
    if: -> { request.format.js? }
  after_action :verify_authorized

  def show
    authorize Bi::WorkHoursCountOrg
    current_user_companies = current_user.user_company_names

    @all_month_names = Bi::WorkHoursCountOrg.all_month_names
    @begin_month_name = params[:begin_month_name]&.strip || @all_month_names.last
    @end_month_name = params[:end_month_name]&.strip || @all_month_names.last
    beginning_of_month = Date.parse(@begin_month_name).beginning_of_month
    end_of_month = Date.parse(@end_month_name).end_of_month

    @short_company_name = params[:company_name]
    if @short_company_name.present?
      @company_name = Bi::StaffCount.company_long_names.fetch(@short_company_name, @short_company_name)
      data = policy_scope(Bi::WorkHoursCountDetailDept).where(date: beginning_of_month..end_of_month).where(orgname: @company_name)
        .select("WORK_HOURS_COUNT_DETAIL_DEPT.deptcode, WORK_HOURS_COUNT_DETAIL_DEPT.deptname, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need")
        .joins("LEFT JOIN SH_REPORT_DEPT_ORDER on SH_REPORT_DEPT_ORDER.deptcode = WORK_HOURS_COUNT_DETAIL_DEPT.deptcode")
        .group("WORK_HOURS_COUNT_DETAIL_DEPT.deptcode, SH_REPORT_DEPT_ORDER.dept_asc, deptname")
        .order("SH_REPORT_DEPT_ORDER.dept_asc, WORK_HOURS_COUNT_DETAIL_DEPT.deptcode")
      data = data.where(orgname: current_user_companies) unless current_user_companies.include?("上海天华建筑设计有限公司")
      job_data = data.having("SUM(date_real) > 0")
      blue_print_data = data.having("SUM(blue_print_real)")
      construction_data = data.having("SUM(construction_real) > 0")
      @job_company_or_department_names = job_data.collect(&:deptname)
      @blue_print_company_or_department_names = blue_print_data.collect(&:deptname)
      @construction_company_or_department_names = construction_data.collect(&:deptname)
      @second_level_drill = true
    else
      data = policy_scope(Bi::WorkHoursCountOrg).where(date: beginning_of_month..end_of_month)
        .select("orgname, orgcode, org_order, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = WORK_HOURS_COUNT_ORG.orgcode")
        .group(:orgcode, :orgname, :org_order)
        .order("ORG_ORDER.org_order DESC")
      job_data = data.having("SUM(date_real) > 0")
      blue_print_data = data.having("SUM(blue_print_real)")
      construction_data = data.having("SUM(construction_real) > 0")
      @job_company_or_department_names = job_data.collect(&:orgname).collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
      @blue_print_company_or_department_names = blue_print_data.collect(&:orgname).collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
      @construction_company_or_department_names = construction_data.collect(&:orgname).collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    end

    @day_rate = job_data.collect { |d| ((d.date_real / d.date_need.to_f) * 100).round(0) rescue 0 }
    @day_rate_ref = params[:day_rate_ref] || 95

    @planning_day_rate = blue_print_data.collect { |d| ((d.blue_print_real / d.blue_print_need.to_f) * 100).round(0) rescue 0 }
    @planning_day_rate_ref = params[:planning_day_rate_ref] || 95

    @building_day_rate = construction_data.collect { |d| ((d.construction_real / d.construction_need.to_f) * 100).round(0) rescue 0 }
    @building_day_rate_ref = params[:building_day_rate_ref] || 80

    @current_user_companies_short_names = current_user_companies.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
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
    @data.select(:deptname, :date, :date_need, :date_real, :fill_rate)
    render
  end

  def planning_day_rate_drill_down
    @data.select(:deptname, :date, :blue_print_need, :blue_print_real, :blue_print_rate)
    render
  end

  def building_day_rate_drill_down
    @data.select(:deptname, :date, :construction_need, :construction_real, :construction_rate)
    render
  end

  private

    def set_drill_down_params_and_title
      authorize Bi::WorkHoursCountDetailStaff
      short_company_name = params[:company_name]
      @company_name = Bi::StaffCount.company_long_names.fetch(short_company_name, short_company_name)
      @department_name = params[:department_name]
      begin_month = Date.parse(params[:begin_month_name]).beginning_of_month
      end_month = Date.parse(params[:end_month_name]).end_of_month
      @drill_down_subtitle = "#{begin_month} - #{end_month}"
      @data = policy_scope(Bi::WorkHoursCountDetailStaff).where(date: begin_month..end_month)
        .where(orgname: @company_name, deptname: @department_name)
        .order(date: :asc)
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.subsidiary_workloading"),
        link: report_subsidiary_workloading_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
