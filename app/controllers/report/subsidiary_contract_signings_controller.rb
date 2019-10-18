# frozen_string_literal: true

class Report::SubsidiaryContractSigningsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized, except: [:show]

  def show
    @short_company_name = params[:company_name]
    authorize Bi::ContractSign if @short_company_name.blank?

    @manual_set_staff_ref = params[:manual_set_staff_ref]&.presence
    @all_month_names = policy_scope(Bi::ContractSign).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    @view_deptcode_sum = params[:view_deptcode_sum] == "true"
    @period_mean_ref = params[:period_mean_ref] || 100
    @cp_contract_amounts_per_staff_ref = if @manual_set_staff_ref
      params[:contract_amounts_per_staff_ref]
    else
      ((100 / 12.0) * @end_of_month.month).round(0)
    end

    current_user_companies = current_user.user_company_names
    @current_user_companies_short_names = current_user_companies.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }

    @company_name = if @short_company_name.present?
      Bi::OrgShortName.company_long_names.fetch(@short_company_name, @short_company_name)
    else
      current_user_companies.first
    end

    @company_short_names = policy_scope(Bi::ContractSignDept)
      .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_SIGN_DEPT.orgcode")
      .order("ORG_ORDER.org_order DESC")
      .select("CONTRACT_SIGN_DEPT.orgcode, ORG_ORDER.org_order").distinct.where("filingtime <= ?", @end_of_month)
      .collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }

    org_code = Bi::OrgShortName.org_code_by_long_name.fetch(@company_name, @company_name)

    data = policy_scope(Bi::ContractSignDept).where("filingtime <= ?", @end_of_month)
      .where(orgcode: org_code)
      .having("SUM(contract_amount) > 0")
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", @end_of_month)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", @end_of_month)

    data = if @view_deptcode_sum
      data.select("CONTRACT_SIGN_DEPT.deptcode_sum deptcode, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_SIGN_DEPT.deptcode_sum")
        .group("CONTRACT_SIGN_DEPT.deptcode_sum, ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_SIGN_DEPT.deptcode_sum")
    else
      data.select("CONTRACT_SIGN_DEPT.deptcode, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_SIGN_DEPT.deptcode")
        .group("CONTRACT_SIGN_DEPT.deptcode, ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_SIGN_DEPT.deptcode")
    end

    @all_department_codes = data.collect(&:deptcode)

    @department_names = @all_department_codes.collect { |c| Bi::PkCodeName.mapping2deptcode.fetch(c, c) }

    @staff_per_dept_code = if org_code == "000101"
      Bi::ShStaffCount.staff_per_dept_code_by_date(@end_of_month)
    else
      Bi::YearAvgStaff.staff_per_dept_code_by_date(org_code, @end_of_month)
    end

    @contract_amounts = data.collect { |d| d.sum_contract_amount.round(0) }
    @contract_amount_max = @contract_amounts.max.round(-1)
    @avg_period_mean = data.collect do |d|
      mean = d.sum_contract_period.to_f / d.sum_contract_amount_count.to_f
      mean.nan? ? 0 : mean.round(0)
    end
    @avg_period_mean_max = @avg_period_mean.max.round(-1)
    @sum_contract_amounts = (@contract_amounts.sum / 10000.to_f).round(2)

    contract_period = data.collect { |d| d.sum_contract_period.to_f }
    contract_count = data.collect { |d| d.sum_contract_amount_count.to_f }
    @sum_avg_period_mean = (contract_period.sum / contract_count.sum).round(0)

    cp_data = policy_scope(Bi::ContractProductionDept)
      .where(orgcode: org_code)
      .having("SUM(total) > 0")
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", @end_of_month)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", @end_of_month)

    cp_data = if @view_deptcode_sum
      cp_data.select("CONTRACT_PRODUCTION_DEPT.deptcode_sum deptcode, ROUND(SUM(total)/10000, 2) cp_amount")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_PRODUCTION_DEPT.deptcode_sum")
        .group("CONTRACT_PRODUCTION_DEPT.deptcode_sum, ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_PRODUCTION_DEPT.deptcode_sum")
    else
      cp_data.select("CONTRACT_PRODUCTION_DEPT.deptcode, ROUND(SUM(total)/10000, 2) cp_amount")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_PRODUCTION_DEPT.deptcode")
        .group("CONTRACT_PRODUCTION_DEPT.deptcode, ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_PRODUCTION_DEPT.deptcode")
    end
    all_cp_department_codes = cp_data.collect(&:deptcode)
    @cp_department_names = all_cp_department_codes.collect { |c| Bi::PkCodeName.mapping2deptcode.fetch(c, c) }
    @cp_contract_amounts = cp_data.collect { |d| d.cp_amount.round(0) }
    @sum_cp_contract_amounts = (@cp_contract_amounts.sum / 10000.to_f).round(2)

    @cp_contract_amounts_per_staff = []
    @cp_contract_amounts.each_with_index do |contract_amount, index|
      dept_code = all_cp_department_codes[index]
      staff_count = @staff_per_dept_code[dept_code]
      staff_count = 1000_0000 if staff_count.nil? || staff_count.zero?
      @cp_contract_amounts_per_staff << (contract_amount / staff_count.to_f).round(0)
    end
  end

  def drill_down_amount
    @company_name = params[:company_name]
    @department_name = params[:department_name]

    belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @department_name)
    if belong_deparments.exists?
      @department_name = belong_deparments.pluck(:部门)
    end
    @data = policy_scope(Bi::ContractSignDetailAmount)
      .where(orgname: @company_name, deptname: @department_name)
      .order(filingtime: :asc)
    authorize @data.first
  end

  def drill_down_date
    @company_name = params[:company_name]
    @department_name = params[:department_name]

    belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @department_name)
    if belong_deparments.exists?
      @department_name = belong_deparments.pluck(:部门)
    end

    @data = policy_scope(Bi::ContractSignDetailDate)
      .where(orgname: @company_name, deptname: @department_name)
      .order(filingtime: :asc)
    authorize @data.first
  end

  def cp_drill_down
    @company_name = params[:company_name]
    @department_name = params[:department_name]

    belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门: @department_name)
    if belong_deparments.exists?
      @department_name = belong_deparments.pluck(:部门)
    end

    @data = policy_scope(Bi::ContractProductionDetail)
      .where(orgname: @company_name, deptname: @department_name)
      .order(filingtime: :asc)
    authorize @data.first
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.contract_signing"),
        link: report_contract_signing_path(view_orgcode_sum: params[:view_orgcode_sum]) },
      { text: t("layouts.sidebar.operation.subsidiary_contract_signing"),
        link: report_subsidiary_contract_signing_path(view_deptcode_sum: true) }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
