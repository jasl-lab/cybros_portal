# frozen_string_literal: true

class Report::SubsidiaryCompleteValuesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::CompleteValueDept
    current_user_companies = current_user.user_company_names
    current_company = current_user_companies.first
    if current_user_companies.include?("上海天华建筑设计有限公司")
      all_orgcodes = Bi::CompleteValueDept.distinct.pluck(:orgcode)
      @all_company_names = all_orgcodes.collect do |c|
        Bi::PkCodeName.mapping2orgcode.fetch(c, c)
      end
      @selected_company_name = params[:company_name]&.strip || current_company
    else
      @all_company_names = current_user_companies
      @selected_company_name = current_company
    end
    @selected_company_name = Bi::StaffCount.company_long_names.fetch(@selected_company_name, @selected_company_name)
    orgcode = Bi::PkCodeName.mapping2org_name.fetch(@selected_company_name, @selected_company_name)
    @selected_short_company_name = Bi::StaffCount.company_short_names.fetch(@selected_company_name, @selected_company_name)
    Rails.logger.debug "orgcode: #{orgcode}"
    @all_month_names = Bi::CompleteValueDept.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month

    last_available_date = policy_scope(Bi::CompleteValueDept).last_available_date(@end_of_month)
    @data = policy_scope(Bi::CompleteValueDept).where(orgcode: orgcode).where(date: last_available_date)
      .select("COMPLETE_VALUE_DEPT.deptcode, dept_asc, SUM(total) sum_total")
      .joins("LEFT JOIN SH_REPORT_DEPT_ORDER on SH_REPORT_DEPT_ORDER.deptcode = COMPLETE_VALUE_DEPT.deptcode")
      .group("COMPLETE_VALUE_DEPT.deptcode, dept_asc")
      .order("SH_REPORT_DEPT_ORDER.dept_asc, COMPLETE_VALUE_DEPT.deptcode")
      .where("SH_REPORT_DEPT_ORDER.dept_asc IS NOT NULL OR COMPLETE_VALUE_DEPT.orgcode != '000101'")

    @all_department_codes = @data.collect(&:deptcode)
    @all_department_names = @all_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    @complete_value_totals = @data.collect { |d| (d.sum_total / 10000.0).round(0) }
    @sum_complete_value_totals = (@complete_value_totals.sum / 10000.0).round(1)
    @complete_value_year_totals = @complete_value_totals.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
    @sum_complete_value_year_totals = (@complete_value_year_totals.sum / 10000.0).round(1)
    @complete_value_year_remains = @complete_value_year_totals.zip(@complete_value_totals).map { |d| d[0] - d[1] }

    @staff_per_dept_code = Bi::ShStaffCount.staff_per_dept_code_by_date(@end_of_month)
    @complete_value_totals_per_staff = @data.collect do |d|
      staff_number = @staff_per_dept_code.fetch(d.deptcode, 1000_0000)
      (d.sum_total / (staff_number * 10000).to_f).round(0)
    end
    @complete_value_year_totals_per_staff = @complete_value_totals_per_staff.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.subsidiary_complete_value"),
        link: report_subsidiary_complete_value_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
