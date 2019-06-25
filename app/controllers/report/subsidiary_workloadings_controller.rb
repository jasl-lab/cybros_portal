class Report::SubsidiaryWorkloadingsController < ApplicationController
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

    short_company_name = params[:company_name]
    if short_company_name.present?
      @company_name = Bi::StaffCount.company_long_names.fetch(short_company_name, short_company_name)
      @data = Bi::WorkHoursCountDetailDept.where(date: beginning_of_month..end_of_month).where(businessltdname: @company_name)
        .select('departmentname, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need')
        .group(:departmentname)
      @data = @data.where(businessltdname: current_user_companies) unless current_user_companies.include?('上海天华建筑设计有限公司')
      @company_or_department_names = @data.collect(&:departmentname)
      @second_level_drill = true
    else
      @data = Bi::WorkHoursCountOrg.where(date: beginning_of_month..end_of_month)
        .select('businessltdname, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need')
        .group(:businessltdname)
      @data = @data.where(businessltdname: current_user_companies) unless current_user_companies.include?('上海天华建筑设计有限公司')
      @company_or_department_names = @data.collect(&:businessltdname).collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    end
    @day_rate = @data.collect { |d| ((d.date_real / d.date_need.to_f) * 100).round(0) rescue 0 }
    @day_rate_ref = params[:day_rate_ref] || 90
    @planning_day_rate = @data.collect { |d| ((d.blue_print_real / d.blue_print_need.to_f) * 100).round(0) rescue 0 }
    @planning_day_rate_ref = params[:planning_day_rate_ref] || 95
    @building_day_rate = @data.collect { |d| ((d.construction_real / d.construction_need.to_f) * 100).round(0) rescue 0 }
    @building_day_rate_ref = params[:building_day_rate_ref] || 80
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
            values << s.company
            values << s.need_days
            values << s.acturally_days
            values << s.planning_need_days
            values << s.planning_acturally_days
            values << s.building_need_days
            values << s.building_acturally_days
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF" << csv_res
      end
    end
  end

  def day_rate_drill_down
    @data.select(:departmentname, :date, :date_need, :date_real, :fill_rate)
    render
  end

  def planning_day_rate_drill_down
    @data.select(:departmentname, :date, :blue_print_need, :blue_print_real, :blue_print_rate)
    render
  end

  def building_day_rate_drill_down
    @data.select(:departmentname, :date, :construction_need, :construction_real, :construction_rate)
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
    @data = Bi::WorkHoursCountDetailStaff.where(date: begin_month..end_month)
      .where(businessltdname: @company_name, departmentname: @department_name)
      .order(date: :asc)
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.subsidiary_workloading"),
      link: report_subsidiary_workloading_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
