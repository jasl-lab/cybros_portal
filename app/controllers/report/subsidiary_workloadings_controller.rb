class Report::SubsidiaryWorkloadingsController < ApplicationController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_month_names = Bi::SubsidiaryWorkloading.all_month_names
    @begin_month_name = params[:begin_month_name]&.strip || @all_month_names.last
    @end_month_name = params[:end_month_name]&.strip || @all_month_names.last
    beginning_of_month = Date.parse(@begin_month_name).beginning_of_month
    end_of_month = Date.parse(@end_month_name).end_of_month
    @data = Bi::SubsidiaryWorkloading.where(date: beginning_of_month..end_of_month)
      .select('company, SUM(acturally_days) acturally_days, SUM(need_days) need_days, SUM(planning_acturally_days) planning_acturally_days, SUM(planning_need_days) planning_need_days, SUM(building_acturally_days), SUM(building_acturally_days) building_acturally_days, SUM(building_need_days) building_need_days')
      .group(:company)
    @company_names = @data.collect(&:company)
    @day_rate = @data.collect { |d| (d.acturally_days / d.need_days.to_f).round(2) }
    @planning_day_rate = @data.collect { |d| (d.planning_acturally_days / d.planning_need_days.to_f).round(2) }
    @building_day_rate = @data.collect { |d| (d.building_acturally_days / d.building_need_days.to_f).round(2) }
  end

  private

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
