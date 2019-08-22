# frozen_string_literal: true

class Report::ContractSigningsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized, except: [:show]

  def show
    @short_company_name = params[:company_name]
    authorize Bi::ContractSign if @short_company_name.blank?
    @manual_set_staff_ref = params[:manual_set_staff_ref]&.presence
    @show_shanghai_hq = params[:show_shanghai_hq]&.presence
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
    @current_user_companies_short_names = current_user_companies.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    if @short_company_name.present?
      @company_name = Bi::StaffCount.company_long_names.fetch(@short_company_name, @short_company_name)
      org_code = Bi::PkCodeName.mapping2org_name.fetch(@company_name, @company_name)
      @data = policy_scope(Bi::ContractSignDept).where("date <= ?", @end_of_month)
        .where(orgcode: org_code)
        .select("CONTRACT_SIGN_DEPT.deptcode, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN SH_REPORT_DEPT_ORDER on SH_REPORT_DEPT_ORDER.deptcode = CONTRACT_SIGN_DEPT.deptcode")
        .group("CONTRACT_SIGN_DEPT.deptcode, SH_REPORT_DEPT_ORDER.dept_asc")
        .having("SUM(contract_amount) > 0")
        .order("SH_REPORT_DEPT_ORDER.dept_asc, CONTRACT_SIGN_DEPT.deptcode")
        .where("(SH_REPORT_DEPT_ORDER.dept_asc IS NOT NULL OR CONTRACT_SIGN_DEPT.orgcode != '000101')")
      @department_or_company_short_names = @data.collect do |d|
        Bi::PkCodeName.mapping2deptcode.fetch(d.deptcode, d.deptcode)
      end
      @second_level_drill = true
      @staff_per_company = Bi::ShStaffCount.staff_per_dept_name_by_date(@end_of_month)
    else
      @data = policy_scope(Bi::ContractSign).where("date <= ?", @end_of_month)
        .select("orgcode, org_order, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_SIGN.orgcode")
        .group(:orgcode, :org_order)
        .having("SUM(contract_amount) > 0")
        .order("ORG_ORDER.org_order DESC")
      @data = @data.where.not(orgcode: "000101") unless @show_shanghai_hq
      all_company_names = @data.collect(&:orgcode).collect do |c|
        Bi::PkCodeName.mapping2orgcode.fetch(c, c)
      end
      @department_or_company_short_names = all_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
      @staff_per_company = Bi::StaffCount.staff_per_short_company_name(@end_of_month)
    end
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
      company_name = @department_or_company_short_names[index]
      staff_count = @staff_per_company[company_name] || 1
      staff_count = 1 if staff_count.zero?
      @contract_amounts_per_staff << (contract_amount / staff_count.to_f).round(0)
    end
  end

  def drill_down_amount
    authorize Bi::ContractSignDetailAmount
    @company_name = params[:company_name]
    @department_name = params[:department_name]
    end_month = Date.parse(params[:month_name]).end_of_month
    @data = policy_scope(Bi::ContractSignDetailAmount).where("filingtime <= ?", end_month)
      .where(orgname: @company_name, deptname: @department_name)
      .order(filingtime: :asc)
  end

  def drill_down_date
    authorize Bi::ContractSignDetailDate
    @company_name = params[:company_name]
    @department_name = params[:department_name]
    end_month = Date.parse(params[:month_name]).end_of_month
    @data = policy_scope(Bi::ContractSignDetailDate).where("contracttime <= ?", end_month)
      .where(orgname: @company_name, deptname: @department_name)
      .order(contracttime: :asc)
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.contract_signing"),
        link: report_contract_signing_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
