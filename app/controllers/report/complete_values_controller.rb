# frozen_string_literal: true

class Report::CompleteValuesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
    authorize Bi::CompleteValue
    @all_month_names = Bi::CompleteValue.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month

    @data = Bi::CompleteValue.where("date <= ?", @end_of_month)
      .where.not(orgcode: "000101") # 上海天华建筑设计有限公司
      .select("orgcode, SUM(total) sum_total")
      .group(:orgcode)
      .having("SUM(total) > 0")
    @all_company_names = @data.collect(&:orgcode).collect do |c|
      Bi::PkCodeName.mapping2orgcode.fetch(c, c)
    end
    @all_company_short_names = @all_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    @complete_value_totals = @data.collect { |d| (d.sum_total / 10000).round(0) }
    @sum_complete_value_totals = (@complete_value_totals.sum / 10000.0).round(1)
    @complete_value_year_totals = @complete_value_totals.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
    @sum_complete_value_year_totals = (@complete_value_year_totals.sum / 10000.0).round(1)
    @staff_per_company = Bi::StaffCount.staff_per_short_company_name
    @complete_value_totals_per_staff = @data.collect do |d|
      company_name = Bi::PkCodeName.mapping2orgcode.fetch(d.orgcode, d.orgcode)
      short_name = Bi::StaffCount.company_short_names.fetch(company_name, company_name)
      staff_number = @staff_per_company.fetch(short_name, 1000)
      (d.sum_total / (staff_number * 10000).to_f).round(0)
    end
    @avg_complete_value_totals_per_staff = (@complete_value_totals_per_staff.sum.to_f / @complete_value_totals_per_staff.size).round(0)
    @complete_value_year_totals_per_staff = @complete_value_totals_per_staff.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
    @avg_complete_value_year_totals_per_staff = (@complete_value_year_totals_per_staff.sum.to_f / @complete_value_year_totals_per_staff.size).round(0)
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.complete_value"),
      link: report_complete_value_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
