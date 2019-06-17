class Report::SubsidiaryWorkloadingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  before_action :set_drill_down_params_and_title, only: %i[day_rate_drill_down planning_day_rate_drill_down building_day_rate_drill_down],
    if: -> { request.format.js? }
  after_action :verify_authorized

  def show
    authorize Bi::SubsidiaryWorkloading
    current_user_companies = current_user.departments.collect(&:company_name)

    @all_month_names = Bi::SubsidiaryWorkloading.all_month_names
    @begin_month_name = params[:begin_month_name]&.strip || @all_month_names.last
    @end_month_name = params[:end_month_name]&.strip || @all_month_names.last
    beginning_of_month = Date.parse(@begin_month_name).beginning_of_month
    end_of_month = Date.parse(@end_month_name).end_of_month
    @data = Bi::SubsidiaryWorkloading.where(date: beginning_of_month..end_of_month)
      .select('company, SUM(acturally_days) acturally_days, SUM(need_days) need_days, SUM(planning_acturally_days) planning_acturally_days, SUM(planning_need_days) planning_need_days, SUM(building_acturally_days), SUM(building_acturally_days) building_acturally_days, SUM(building_need_days) building_need_days')
      .group(:company)
    @data = @data.where(company: current_user_companies) unless current_user_companies.include?('上海天华建筑设计有限公司')
    @company_names = @data.collect(&:company).collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    @day_rate = @data.collect { |d| ((d.acturally_days / d.need_days.to_f) * 100).round(0) }
    @day_rate_ref = params[:day_rate_ref] || 90
    @planning_day_rate = @data.collect { |d| ((d.planning_acturally_days / d.planning_need_days.to_f) * 100).round(0) }
    @planning_day_rate_ref = params[:planning_day_rate_ref] || 95
    @building_day_rate = @data.collect { |d| ((d.building_acturally_days / d.building_need_days.to_f) * 100).round(0) }
    @building_day_rate_ref = params[:building_day_rate_ref] || 80
  end

  def export
    authorize Bi::SubsidiaryWorkloading

    respond_to do |format|
      format.csv do
        render_csv_header 'Subsidiary Workloadings'
        csv_res = CSV.generate do |csv|
          csv << ['ID', '日期', '公司', '天数需填', '天数实填', '方案需填', '方案实填', '施工图需填', '施工图实填']
          policy_scope(Bi::SubsidiaryWorkloading).order(id: :asc).find_each do |s|
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
    authorize Bi::SubsidiaryWorkloading
    @company_name = params[:company_name]
    begin_month = Date.parse(params[:begin_month_name]).beginning_of_month
    end_month = Date.parse(params[:end_month_name]).end_of_month
    @drill_down_subtitle = "#{begin_month} - #{end_month}"
    @data = Bi::WorkHoursCount.where(date: begin_month..end_month).where(businessltdname: @company_name).order(date: :asc)
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
