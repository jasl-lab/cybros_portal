# frozen_string_literal: true

class Report::SubsidiaryContractSigningsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    @short_company_name = params[:company_name]
    authorize Bi::ContractSign if @short_company_name.blank?
    prepare_meta_tags title: t(".title")

    @manual_set_staff_ref = params[:manual_set_staff_ref]&.presence
    @all_month_names = policy_scope(Bi::ContractSignDept, :group_resolve).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    raise Pundit::NotAuthorizedError if @month_name.blank?
    @end_of_month = Date.parse(@month_name).end_of_month
    @beginning_of_year = Date.parse(@month_name).beginning_of_year
    @view_deptcode_sum = params[:view_deptcode_sum] == "true"
    @period_mean_ref = params[:period_mean_ref] || 100
    @cp_contract_amounts_per_staff_ref = if @manual_set_staff_ref
      params[:contract_amounts_per_staff_ref]
    else
      ((100 / 12.0) * @end_of_month.month).round(0)
    end

    current_user_companies = current_user.user_company_names

    @company_name = if @short_company_name.present?
      Bi::OrgShortName.company_long_names.fetch(@short_company_name, @short_company_name)
    else
      current_user_companies.first
    end

    @last_available_sign_dept_date = policy_scope(Bi::ContractSignDept, :group_resolve).last_available_date(@end_of_month)
    @company_short_names = policy_scope(Bi::ContractSignDept, :group_resolve).where(date: @last_available_sign_dept_date)
      .where('ORG_ORDER.org_order is not null')
      .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_SIGN_DEPT.orgcode')
      .order("ORG_ORDER.org_order DESC")
      .select("CONTRACT_SIGN_DEPT.orgcode, ORG_ORDER.org_order").distinct.where(filingtime: @beginning_of_year..@end_of_month)
      .collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }

    org_code = Bi::OrgShortName.org_code_by_long_name.fetch(@company_name, @company_name)

    data = policy_scope(Bi::ContractSignDept, :group_resolve).where(filingtime: @beginning_of_year..@end_of_month).where(date: @last_available_sign_dept_date)
      .where(orgcode: org_code)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", @end_of_month)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", @end_of_month)

    data = if @view_deptcode_sum
      data.select("CONTRACT_SIGN_DEPT.deptcode_sum deptcode, ROUND(SUM(IFNULL(contract_amount,0))/10000, 2) sum_contract_amount, SUM(IFNULL(contract_period,0)) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_SIGN_DEPT.deptcode_sum")
        .group("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_SIGN_DEPT.deptcode_sum")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_SIGN_DEPT.deptcode_sum")
    else
      data.select("CONTRACT_SIGN_DEPT.deptcode, ROUND(SUM(IFNULL(contract_amount,0))/10000, 2) sum_contract_amount, SUM(IFNULL(contract_period,0)) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_SIGN_DEPT.deptcode")
        .group("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_SIGN_DEPT.deptcode")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_SIGN_DEPT.deptcode")
    end

    @all_department_codes = data.collect(&:deptcode)

    @department_names = @all_department_codes.collect { |c| Bi::PkCodeName.mapping2deptcode.fetch(c, c) }

    @staff_per_dept_code = if org_code == '000101' && @end_of_month.year < 2020
      Bi::ShStaffCount.staff_per_dept_code_by_date(@end_of_month)
    else
      Bi::YearAvgStaff.worker_per_dept_code_by_date_and_sum(org_code, @end_of_month, @view_deptcode_sum)
    end

    @contract_amounts = data.collect { |d| d.sum_contract_amount.to_f.round(0) }
    @contract_amount_max = @contract_amounts.max&.round(-1)
    @avg_period_mean = data.collect do |d|
      mean = d.sum_contract_period.to_f / d.sum_contract_amount_count.to_f
      mean.nan? ? 0 : mean.round(0)
    end
    @avg_period_mean_max = @avg_period_mean.max&.round(-1)
    @sum_contract_amounts = (policy_scope(Bi::ContractSignDept, :group_resolve).where(filingtime: @beginning_of_year..@end_of_month).where(orgcode: org_code).where(date: @last_available_sign_dept_date)
      .select("ROUND(SUM(contract_amount)/10000, 2) sum_contract_amounts").first&.sum_contract_amounts.to_f / 10000.to_f).round(2)

    contract_period = data.collect { |d| d.sum_contract_period.to_f }
    contract_count = data.collect { |d| d.sum_contract_amount_count.to_f }
    @sum_avg_period_mean = if contract_count.sum.zero?
      0
    else
      (contract_period.sum / contract_count.sum).round(0)
    end

    @last_available_production_dept_date = policy_scope(Bi::ContractProductionDept, :group_resolve).last_available_date(@end_of_month)
    cp_data = policy_scope(Bi::ContractProductionDept, :group_resolve).where(filingtime: @beginning_of_year..@end_of_month).where(date: @last_available_production_dept_date)
      .where(orgcode: org_code)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", @end_of_month)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", @end_of_month)

    cp_data = if @view_deptcode_sum
      cp_data.select("CONTRACT_PRODUCTION_DEPT.deptcode_sum deptcode, ROUND(SUM(IFNULL(total,0))/10000, 2) cp_amount")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_PRODUCTION_DEPT.deptcode_sum")
        .group("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_PRODUCTION_DEPT.deptcode_sum")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_PRODUCTION_DEPT.deptcode_sum")
    else
      cp_data.select("CONTRACT_PRODUCTION_DEPT.deptcode, ROUND(SUM(IFNULL(total,0))/10000, 2) cp_amount")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_PRODUCTION_DEPT.deptcode")
        .group("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_PRODUCTION_DEPT.deptcode")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_PRODUCTION_DEPT.deptcode")
    end
    @all_cp_department_codes = cp_data.collect(&:deptcode)
    @cp_department_names = @all_cp_department_codes.collect { |c| Bi::PkCodeName.mapping2deptcode.fetch(c, c) }
    @cp_contract_amounts = cp_data.collect { |d| d.cp_amount.round(0) }
    @sum_cp_contract_amounts = (policy_scope(Bi::ContractProductionDept, :group_resolve).where(filingtime: @beginning_of_year..@end_of_month).where(orgcode: org_code).where(date: @last_available_production_dept_date)
      .select("ROUND(SUM(IFNULL(total,0))/10000, 2) cp_amounts").first.cp_amounts.to_f / 10000.to_f).round(2)

    @cp_contract_amounts_per_staff = []
    @cp_contract_amounts.each_with_index do |contract_amount, index|
      dept_code = @all_cp_department_codes[index]
      staff_count = @staff_per_dept_code[dept_code]
      staff_count = Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM if staff_count.nil? || staff_count.zero?
      @cp_contract_amounts_per_staff << (contract_amount / staff_count.to_f).round(0)
    end
  end

  def drill_down_amount
    @company_name = params[:company_name]
    @view_deptcode_sum = params[:view_deptcode_sum] == "true"
    @department_name = [params[:department_name]]
    department_code = params[:department_code]
    month_name = params[:month_name]&.strip || policy_scope(Bi::ContractSignDept).all_month_names.first
    beginning_of_year = Date.parse(month_name).beginning_of_year
    end_of_year = Date.parse(month_name).end_of_year
    end_of_month = Date.parse(month_name).end_of_month

    if @view_deptcode_sum
      belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @department_name)
      if belong_deparments.exists?
        @department_name += belong_deparments.pluck(:部门).reject { |dept_name| dept_name.include?('撤销') }
      end
    end

    last_available_date = policy_scope(Bi::ContractSignDetailAmount).last_available_date(end_of_month)
    @data = policy_scope(Bi::ContractSignDetailAmount).where(deptname: @department_name).or(policy_scope(Bi::ContractSignDetailAmount).where(deptcode: department_code))
      .where(date: last_available_date)
      .where(orgname: @company_name)
      .where(filingtime: beginning_of_year..end_of_year)
      .order(filingtime: :asc)
    authorize @data.first if @data.present?
  end

  def drill_down_date
    @company_name = params[:company_name]
    @department_name = [params[:department_name]]
    month_name = params[:month_name]&.strip
    end_of_month = Date.parse(month_name).end_of_month

    belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @department_name)
    if belong_deparments.exists?
      @department_name += belong_deparments.pluck(:部门).reject { |dept_name| dept_name.include?('撤销') }
    end

    @data = policy_scope(Bi::ContractSignDetailDate)
      .where(orgname: @company_name, deptname: @department_name)
      .where(filingtime: end_of_month.beginning_of_year..end_of_month)
      .order(filingtime: :asc)
    authorize @data.first if @data.present?
  end

  def cp_drill_down
    @company_name = params[:company_name]
    month_name = params[:month_name]
    beginning_of_year = Date.parse(month_name).beginning_of_year
    end_of_year = Date.parse(month_name).end_of_year

    @department_name = [params[:department_name]]

    belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @department_name)
    if belong_deparments.exists?
      @department_name += belong_deparments.pluck(:部门).reject { |dept_name| dept_name.include?('撤销') }
    end

    last_available_sign_dept_date = Date.parse(params[:last_available_sign_dept_date])
    @data = policy_scope(Bi::ContractProductionDetail).where(date: last_available_sign_dept_date)
      .where(orgname: @company_name, deptname: @department_name)
      .where(filingtime: beginning_of_year..end_of_year)
      .order(filingtime: :asc)
    authorize @data.first if @data.present?
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.contract_signing"),
        link: report_contract_signing_path(view_orgcode_sum: true) },
      { text: t("layouts.sidebar.operation.subsidiary_contract_signing"),
        link: report_subsidiary_contract_signing_path(view_deptcode_sum: true) }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
