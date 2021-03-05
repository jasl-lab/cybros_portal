# frozen_string_literal: true

class Report::SubsidiaryCompleteValuesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    authorize Bi::CompleteValueDept
    current_user_companies = current_user.user_company_names
    current_company = current_user_companies.first
    if current_user.roles.pluck(:report_view_all).any? || current_user.admin?
      all_orgcodes = Bi::CompleteValueDept
        .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = COMPLETE_VALUE_DEPT.orgcode')
        .where('ORG_ORDER.org_order is not null')
        .where("ORG_ORDER.org_type = '创意板块'")
        .order('ORG_ORDER.org_order ASC')
        .pluck(:orgcode).uniq
      all_company_names = all_orgcodes.collect do |c|
        Bi::OrgShortName.company_long_names_by_orgcode.fetch(c, c)
      end
      @selected_company_name = params[:company_name]&.strip || current_company
    else
      all_company_names = current_user_companies
      @selected_company_name = params[:company_name]&.strip || current_company
    end
    @all_short_company_names = all_company_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @selected_company_name = Bi::OrgShortName.company_long_names.fetch(@selected_company_name, @selected_company_name)
    prepare_meta_tags title: t('.title', company: @selected_company_name)
    orgcode = Bi::OrgShortName.org_code_by_long_name.fetch(@selected_company_name, @selected_company_name)
    @selected_short_company_name = Bi::OrgShortName.company_short_names.fetch(@selected_company_name, @selected_company_name)
    Rails.logger.debug "orgcode: #{orgcode}"
    @all_month_names = policy_scope(Bi::CompleteValueDept, :group_resolve).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @end_of_month = Date.parse(@month_name).end_of_month
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'

    last_available_date = policy_scope(Bi::CompleteValueDept, :group_resolve).last_available_date(@end_of_month)
    data = policy_scope(Bi::CompleteValueDept, :group_resolve).where(orgcode: orgcode).or(policy_scope(Bi::CompleteValueDept).where(orgcode_sum: orgcode))
      .where(month: @end_of_month.beginning_of_year..@end_of_month).where(date: last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', last_available_date)
      .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', last_available_date)

    data = if @view_deptcode_sum
      data.select('COMPLETE_VALUE_DEPT.deptcode_sum deptcode, 部门排名, SUM(IFNULL(total,0)) sum_total')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = COMPLETE_VALUE_DEPT.deptcode_sum')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, COMPLETE_VALUE_DEPT.deptcode_sum')
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, COMPLETE_VALUE_DEPT.deptcode_sum'))
    else
      data.select('COMPLETE_VALUE_DEPT.deptcode, 部门排名, SUM(IFNULL(total,0)) sum_total')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = COMPLETE_VALUE_DEPT.deptcode')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, COMPLETE_VALUE_DEPT.deptcode')
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, COMPLETE_VALUE_DEPT.deptcode'))
    end

    @all_department_codes = data.collect(&:deptcode)
    @all_department_names = @all_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end
    @complete_value_totals = data.collect { |d| (d.sum_total / 10000.0).round(0) }

    data_deptcode_sub_sum = policy_scope(Bi::CompleteValueDept, :group_resolve).where(orgcode: orgcode)
        .where(month: @end_of_month.beginning_of_year..@end_of_month)
        .where(date: last_available_date)
        .select('SUM(IFNULL(total,0)) sub_sum_total')
    @fix_sum_complete_value_totals = (data_deptcode_sub_sum.first.sub_sum_total / 10000.0).round(1)

    @complete_value_year_totals = @complete_value_totals.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }

    @fix_sum_complete_value_year_totals = (@fix_sum_complete_value_totals / (@end_of_month.month / 12.0)).round(1)

    @complete_value_year_remains = @complete_value_year_totals.zip(@complete_value_totals).map { |d| d[0] - d[1] }

    worker_per_dept_code_by_year = if orgcode == '000101' && @end_of_month.year <= 2020 && @end_of_month.month < 5
      Bi::ShStaffCount.staff_count_per_dept_code_by_date(@end_of_month)
    else
      Bi::YearAvgWorker.worker_per_dept_code_by_year_and_sum(orgcode, @end_of_month, @view_deptcode_sum)
    end

    @staff_per_dept_code = if orgcode == '000101' && @end_of_month.year <= 2020 && @end_of_month.month < 5
      Bi::ShStaffCount.staff_count_per_dept_code_by_date(@end_of_month)
    else
      Bi::YearAvgWorker.worker_per_dept_code_by_date_and_sum(orgcode, @end_of_month, @view_deptcode_sum)
    end

    @complete_value_totals_per_staff = data.collect do |d|
      staff_number = @staff_per_dept_code.fetch(d.deptcode, Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM)
      (d.sum_total / ((staff_number.zero? ? Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM : staff_number) * 10000).to_f).round(0)
    end

    @complete_value_year_totals_per_staff = data.collect do |d|
      staff_number = worker_per_dept_code_by_year.fetch(d.deptcode, Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM)
      (d.sum_total / ((staff_number.zero? ? Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM : staff_number) * 10000).to_f).round(0)
    end

    @complete_value_gap_per_staff = @complete_value_year_totals_per_staff.zip(@complete_value_totals_per_staff).map { |d| d[0] - d[1] }
    @total_staff_num = Bi::YearAvgWorker.fix_worker_by_date_and_sum(orgcode, @end_of_month)
  end

  def drill_down
    @company_name = params[:company_name].strip
    @dept_name = [params[:department_name].strip]

    month_name = params[:month_name]&.strip
    end_of_month = Date.parse(month_name).end_of_month

    belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @dept_name)
    if belong_deparments.exists?
      @dept_name += belong_deparments.pluck(:部门).reject { |dept_name| dept_name.include?('撤销') }
    end

    @rows = policy_scope(Bi::CompleteValueDetail)
      .select('contractcode, salescontractname, projectcode, projectname, confirmdate, SUM(IFNULL(sumamount,0)) sumamount')
      .group('contractcode, salescontractname, projectcode, projectname, confirmdate')
      .where(orgname: @company_name, deptname: @dept_name)
      .where(confirmdate: end_of_month.beginning_of_year..end_of_month)
    render
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.complete_value'),
        link: report_complete_value_path(view_orgcode_sum: true) },
      { text: t('layouts.sidebar.operation.subsidiary_complete_value'),
        link: report_subsidiary_complete_value_path(view_deptcode_sum: true) }]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
