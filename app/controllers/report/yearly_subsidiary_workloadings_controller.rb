class Report::YearlySubsidiaryWorkloadingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    current_user_companies = current_user.departments.collect(&:company_name)
    current_company = current_user_companies.first
    if current_user_companies.include?('上海天华建筑设计有限公司')
      @all_company_names = Bi::SubsidiaryWorkloading.distinct.pluck(:company)
      @selected_company_name = params[:company_name]&.strip || current_company
    else
      @all_company_names = current_user_companies
      @selected_company_name = current_company
    end

    all_month_names = Bi::SubsidiaryWorkloading.all_month_names
    beginning_of_month = Date.parse(all_month_names.first).beginning_of_month
    end_of_month = Date.parse(all_month_names.last).end_of_month
    data = Bi::SubsidiaryWorkloading.where(date: beginning_of_month..end_of_month, company: @selected_company_name)
    @dates = data.collect(&:date)
    @day_rate = data.collect { |d| ((d.acturally_days / d.need_days.to_f) * 100).round(2) }
    @day_rate_ref = params[:day_rate_ref] || 90
    @planning_day_rate = data.collect { |d| ((d.planning_acturally_days / d.planning_need_days.to_f) * 100).round(2) }
    @planning_day_rate_ref = params[:planning_day_rate_ref] || 95
    @building_day_rate = data.collect { |d| ((d.building_acturally_days / d.building_need_days.to_f) * 100).round(2) }
    @building_day_rate_ref = params[:building_day_rate_ref] || 80
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.yearly_subsidiary_workloading"),
      link: report_yearly_subsidiary_workloading_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
