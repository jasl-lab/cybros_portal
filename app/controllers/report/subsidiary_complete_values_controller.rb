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
      all_company_names = all_orgcodes.collect do |c|
        Bi::OrgShortName.company_long_names_by_orgcode.fetch(c, c)
      end
      @selected_company_name = params[:company_name]&.strip || current_company
    else
      all_company_names = current_user_companies
      @selected_company_name = current_company
    end
    @all_short_company_names = all_company_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @selected_company_name = Bi::OrgShortName.company_long_names.fetch(@selected_company_name, @selected_company_name)
    orgcode = Bi::OrgShortName.org_code_by_long_name.fetch(@selected_company_name, @selected_company_name)
    @selected_short_company_name = Bi::OrgShortName.company_short_names.fetch(@selected_company_name, @selected_company_name)
    Rails.logger.debug "orgcode: #{orgcode}"
    @all_month_names = Bi::CompleteValueDept.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    @view_deptcode_sum = params[:view_deptcode_sum] == "true"


    last_available_date = policy_scope(Bi::CompleteValueDept).last_available_date(@end_of_month)
    data = policy_scope(Bi::CompleteValueDept).where(orgcode: orgcode).where(date: last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", last_available_date)

    data = if @view_deptcode_sum
      data.select("COMPLETE_VALUE_DEPT.deptcode_sum deptcode, 部门排名, SUM(total) sum_total")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = COMPLETE_VALUE_DEPT.deptcode_sum")
        .group("COMPLETE_VALUE_DEPT.deptcode_sum, ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, COMPLETE_VALUE_DEPT.deptcode_sum")
    else
      data.select("COMPLETE_VALUE_DEPT.deptcode, 部门排名, SUM(total) sum_total")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = COMPLETE_VALUE_DEPT.deptcode")
        .group("COMPLETE_VALUE_DEPT.deptcode, ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, COMPLETE_VALUE_DEPT.deptcode")
    end

    @all_department_codes = data.collect(&:deptcode)
    @all_department_names = @all_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    @complete_value_totals = data.collect { |d| (d.sum_total / 10000.0).round(0) }
    @sum_complete_value_totals = (@complete_value_totals.sum / 10000.0).round(1)
    @complete_value_year_totals = @complete_value_totals.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
    @sum_complete_value_year_totals = (@complete_value_year_totals.sum / 10000.0).round(1)
    @complete_value_year_remains = @complete_value_year_totals.zip(@complete_value_totals).map { |d| d[0] - d[1] }

    @staff_per_dept_code = Bi::YearAvgStaff.staff_per_dept_code_by_date(orgcode, @end_of_month)
    @complete_value_totals_per_staff = data.collect do |d|
      staff_number = @staff_per_dept_code.fetch(d.deptcode, 1000_0000)
      (d.sum_total / (staff_number * 10000).to_f).round(0)
    end
    @complete_value_year_totals_per_staff = @complete_value_totals_per_staff.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
  end

  def drill_down
    @company_name = params[:company_name].strip
    @dept_name = params[:department_name].strip

    month_name = params[:month_name]&.strip
    end_of_month = Date.parse(month_name).end_of_month
    beginning_of_month = Date.parse(month_name).beginning_of_month

    last_available_date = policy_scope(Bi::TrackContract).where(date: beginning_of_month..end_of_month).order(date: :desc).first.date
    @rows = policy_scope(Bi::CompleteValueDetail).where(orgname: @company_name, deptname: @dept_name, date: last_available_date)
    render
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.subsidiary_complete_value"),
        link: report_subsidiary_complete_value_path(view_deptcode_sum: true) }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
