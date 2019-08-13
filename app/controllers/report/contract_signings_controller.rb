# frozen_string_literal: true

class Report::ContractSigningsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized, except: [:show]

  def show
    @short_company_name = params[:company_name]
    authorize Bi::ContractSign if @short_company_name.blank?
    @all_month_names = policy_scope(Bi::ContractSign).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    @period_mean_ref = params[:period_mean_ref] || 100
    @contract_amounts_per_staff_ref = params[:contract_amounts_per_staff_ref] || ((100 / 12.0) * @end_of_month.month).round(0)

    current_user_companies = current_user.user_company_names
    @current_user_companies_short_names = current_user_companies.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    if @short_company_name.present?
      @company_name = Bi::StaffCount.company_long_names.fetch(@short_company_name, @short_company_name)
      org_code = Bi::PkCodeName.mapping2org_name.fetch(@company_name, @company_name)
      @data = policy_scope(Bi::ContractSignDept).where("date <= ?", @end_of_month)
        .where(orgcode: org_code)
        .select("deptcode, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .group(:deptcode)
        .having("SUM(contract_amount) > 0")
      @department_or_company_short_names = @data.collect do |d|
        Bi::PkCodeName.mapping2deptcode.fetch(d.deptcode, d.deptcode)
      end

      @second_level_drill = true
    else
      @data = policy_scope(Bi::ContractSign).where("date <= ?", @end_of_month)
        .where.not(orgcode: "000101") # 上海天华建筑设计有限公司
        .select("orgcode, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .group(:orgcode)
        .having("SUM(contract_amount) > 0")
      all_company_names = @data.collect(&:orgcode).collect do |c|
        Bi::PkCodeName.mapping2orgcode.fetch(c, c)
      end
      @department_or_company_short_names = all_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
      @staff_per_company = Bi::StaffCount.staff_per_company
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
  end

  def drill_down
    authorize Bi::ContractSignDetailAmount
    @company_name = params[:company_name]
    @department_name = params[:department_name]
    end_month = Date.parse(params[:month_name]).end_of_month
    @data = policy_scope(Bi::ContractSignDetailAmount).where('filingtime <= ?', end_month)
      .where(orgname: @company_name, deptname: @department_name)
      .order(filingtime: :asc)
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("report.contract_signings.show.title", company: params[:company_name]),
      link: report_contract_signing_path(company_name: params[:company_name]) }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
