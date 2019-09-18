# frozen_string_literal: true

class Report::ContractSigningsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized, except: [:show]

  def show
    authorize Bi::ContractSign
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
    @company_short_names = all_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    @staff_per_company = Bi::StaffCount.staff_per_short_company_name(@end_of_month)

    @contract_amounts = @data.collect { |d| d.sum_contract_amount.round(0) }
    @contract_amounts_div_100 = @data.collect { |d| (d.sum_contract_amount / 100.0).round(0) }
    @contract_amount_max = 250
    @avg_period_mean = @data.collect do |d|
      mean = d.sum_contract_period.to_f / d.sum_contract_amount_count.to_f
      mean.nan? ? 0 : mean.round(0)
    end
    @avg_period_mean_max = 150

    @sum_contract_amounts = (policy_scope(Bi::ContractSign).where("date <= ?", @end_of_month)
      .select("ROUND(SUM(contract_amount)/10000, 2) sum_contract_amounts").first.sum_contract_amounts / 10000.to_f).round(2)

    df = policy_scope(Bi::ContractSign).where("date <= ?", @end_of_month)
      .select("SUM(contract_period) one_sum_contract_period, SUM(count) one_sum_contract_amount_count").first
    one_sum_contract_period = df.one_sum_contract_period
    one_sum_contract_amount_count = df.one_sum_contract_amount_count
    @sum_avg_period_mean = (one_sum_contract_period / one_sum_contract_amount_count).round(0)

    @contract_amounts_per_staff = []
    @contract_amounts.each_with_index do |contract_amount, index|
      company_name = @company_short_names[index]
      staff_count = @staff_per_company[company_name] || 1000_0000
      staff_count = 1 if staff_count.nil? || staff_count.zero?
      @contract_amounts_per_staff << (contract_amount / staff_count.to_f).round(0)
    end
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
