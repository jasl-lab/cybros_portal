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
    @period_mean_ref = params[:period_mean_ref] || 100
    @contract_amounts_per_staff_ref = if @manual_set_staff_ref
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
      .select("CONTRACT_SIGN_DEPT.orgcode, ORG_ORDER.org_order").distinct.where("date <= ?", @end_of_month)
      .collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }

    org_code = Bi::OrgShortName.org_code_by_long_name.fetch(@company_name, @company_name)
    @data = policy_scope(Bi::ContractSignDept).where("date <= ?", @end_of_month)
      .where(orgcode: org_code)
      .select("CONTRACT_SIGN_DEPT.deptcode, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
      .joins("LEFT JOIN SH_REPORT_DEPT_ORDER on SH_REPORT_DEPT_ORDER.deptcode = CONTRACT_SIGN_DEPT.deptcode")
      .group("CONTRACT_SIGN_DEPT.deptcode, SH_REPORT_DEPT_ORDER.dept_asc")
      .having("SUM(contract_amount) > 0")
      .order("SH_REPORT_DEPT_ORDER.dept_asc, CONTRACT_SIGN_DEPT.deptcode")
      .where("(SH_REPORT_DEPT_ORDER.dept_asc IS NOT NULL OR CONTRACT_SIGN_DEPT.orgcode != '000101')")
    @department_names = @data.collect do |d|
      Bi::PkCodeName.mapping2deptcode.fetch(d.deptcode, d.deptcode)
    end

    @all_department_codes = @data.collect(&:deptcode)
    @staff_per_dept_code = Bi::YearAvgStaff.staff_per_dept_code_by_date(org_code, @end_of_month)

    @contract_amounts = @data.collect { |d| d.sum_contract_amount.round(0) }
    @contract_amount_max = @contract_amounts.max.round(-1)
    @avg_period_mean = @data.collect do |d|
      mean = d.sum_contract_period.to_f / d.sum_contract_amount_count.to_f
      mean.nan? ? 0 : mean.round(0)
    end
    @avg_period_mean_max = @avg_period_mean.max.round(-1)
    @sum_contract_amounts = (@contract_amounts.sum / 10000.to_f).round(2)

    contract_period = @data.collect { |d| d.sum_contract_period.to_f }
    contract_count = @data.collect { |d| d.sum_contract_amount_count.to_f }
    @sum_avg_period_mean = (contract_period.sum / contract_count.sum).round(0)

    @contract_amounts_per_staff = []
    @contract_amounts.each_with_index do |contract_amount, index|
      dept_code = @all_department_codes[index]
      staff_count = @staff_per_dept_code[dept_code]
      staff_count = 1 if staff_count.nil? || staff_count.zero?
      @contract_amounts_per_staff << (contract_amount / staff_count.to_f).round(0)
    end
  end

  def drill_down_amount
    @company_name = params[:company_name]
    @department_name = params[:department_name]
    end_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractSignDetailAmount).last_available_date(end_month)

    @data = policy_scope(Bi::ContractSignDetailAmount).where(date: last_available_date)
      .where(orgname: @company_name, deptname: @department_name)
      .order(filingtime: :asc)
    authorize @data.first
  end

  def drill_down_date
    @company_name = params[:company_name]
    @department_name = params[:department_name]
    end_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractSignDetailDate).last_available_date(end_month)

    @data = policy_scope(Bi::ContractSignDetailDate).where(date: last_available_date)
      .where(orgname: @company_name, deptname: @department_name)
      .order(contracttime: :asc)
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
        link: report_subsidiary_contract_signing_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
