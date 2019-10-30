# frozen_string_literal: true

class Report::ContractSigningsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized, except: [:show]

  def show
    authorize Bi::ContractSign
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
    @orgs_options = params[:orgs]
    @view_orgcode_sum = params[:view_orgcode_sum] == "true"
    current_user_companies = current_user.user_company_names
    @current_user_companies_short_names = current_user_companies.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    selected_short_name = params[:company_name]&.strip

    data = policy_scope(Bi::ContractSign).where("filingtime <= ?", @end_of_month)
      .having("SUM(contract_amount) > 0")
      .order("ORG_ORDER.org_order DESC")

    data = if @view_orgcode_sum
      data.select("orgcode_sum orgcode, org_order, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_SIGN.orgcode_sum")
        .group(:orgcode_sum, :org_order)
    else
      data.select("orgcode, org_order, ROUND(SUM(contract_amount)/10000, 2) sum_contract_amount, SUM(contract_period) sum_contract_period, SUM(count) sum_contract_amount_count")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_SIGN.orgcode")
        .group(:orgcode, :org_order)
    end

    all_company_orgcodes = data.collect(&:orgcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ["000101"] if @orgs_options.blank?
    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @sum_org_names = @organization_options.reject { |k, v| !v.start_with?("H") }.collect(&:first)

    if selected_short_name.present?
      selected_sum_h_code = Bi::OrgShortName.org_code_by_short_name.fetch(selected_short_name, selected_short_name)
      @orgs_options = Bi::CompleteValue.where(orgcode_sum: selected_sum_h_code).pluck(:orgcode)
    end

    data = if @view_orgcode_sum
      data.where(orgcode_sum: @orgs_options)
    else
      data.where(orgcode: @orgs_options)
    end

    @company_short_names = data.collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }

    @contract_amounts = data.collect { |d| d.sum_contract_amount.round(0) }
    @contract_amounts_div_100 = data.collect { |d| (d.sum_contract_amount / 100.0).round(0) }
    @contract_amount_max = 260
    @avg_period_mean = data.collect do |d|
      mean = d.sum_contract_period.to_f / d.sum_contract_amount_count.to_f
      mean.nan? ? 0 : mean.round(0)
    end
    @avg_period_mean_max = 150

    @sum_contract_amounts = (policy_scope(Bi::ContractSign).where("filingtime <= ?", @end_of_month)
      .select("ROUND(SUM(contract_amount)/10000, 2) sum_contract_amounts").first.sum_contract_amounts / 10000.to_f).round(2)

    df = policy_scope(Bi::ContractSign).where("filingtime <= ?", @end_of_month)
      .select("SUM(contract_period) one_sum_contract_period, SUM(count) one_sum_contract_amount_count").first
    one_sum_contract_period = df.one_sum_contract_period
    one_sum_contract_amount_count = df.one_sum_contract_amount_count
    @sum_avg_period_mean = (one_sum_contract_period / one_sum_contract_amount_count).round(0)


    cp_data = policy_scope(Bi::ContractProductionDept)
      .having("SUM(total) > 0")
      .order("ORG_ORDER.org_order DESC")

    cp_data = if @view_orgcode_sum
      cp_data.select("CONTRACT_PRODUCTION_DEPT.orgcode_sum orgcode, org_order, ROUND(SUM(total)/10000, 2) cp_amount")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_PRODUCTION_DEPT.orgcode_sum")
        .group(:orgcode_sum, :org_order)
        .where(orgcode_sum: @orgs_options)
    else
      cp_data.select("CONTRACT_PRODUCTION_DEPT.orgcode, org_order, ROUND(SUM(total)/10000, 2) cp_amount")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_PRODUCTION_DEPT.orgcode")
        .group(:orgcode, :org_order)
        .where(orgcode: @orgs_options)
    end
    @cp_org_names = cp_data.collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }
    @cp_contract_amounts = cp_data.collect { |d| d.cp_amount.round(0) }
    @cp_contract_amounts_div_100 = cp_data.collect { |d| (d.cp_amount / 100.0).round(0) }
    @sum_cp_contract_amounts = (@cp_contract_amounts.sum / 10000.to_f).round(2)

    @staff_per_company = Bi::StaffCount.staff_per_short_company_name(@end_of_month)
    @production_amounts_per_staff = []
    @cp_contract_amounts.each_with_index do |contract_amount, index|
      company_name = @cp_org_names[index]
      staff_count = @staff_per_company[company_name] || Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM
      staff_count = Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM if staff_count.nil? || staff_count.zero?
      @production_amounts_per_staff << (contract_amount / staff_count.to_f).round(0)
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
        link: report_contract_signing_path(view_orgcode_sum: params[:view_orgcode_sum]) }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
