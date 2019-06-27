class Report::SubsidiaryCompleteValuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::CompleteValue
    current_user_companies = current_user.user_company_names
    current_company = current_user_companies.first
    if current_user_companies.include?('上海天华建筑设计有限公司')
      @all_company_names = Bi::CompleteValue.distinct.pluck(:businessltdname)
      @selected_company_name = params[:company_name]&.strip || current_company
    else
      @all_company_names = current_user_companies
      @selected_company_name = current_company
    end
    @all_month_names = Bi::CompleteValue.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    end_of_month = Date.parse(@month_name).end_of_month

    @data = Bi::CompleteValue.where(businessltdname: @selected_company_name).where('date <= ?', end_of_month)
      .select('departmentname, SUM(total) sum_total')
      .group(:departmentname)
    @all_department_names = @data.collect(&:departmentname)
    @complete_value_totals = @data.collect { |d| (d.sum_total/10000).round(0) }
    @complete_value_year_totals = @complete_value_totals.collect { |d| (d / (end_of_month.month/12.0)).round(0) }
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.subsidiary_complete_value"),
      link: report_subsidiary_complete_value_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
