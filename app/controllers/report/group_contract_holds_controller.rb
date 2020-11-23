# frozen_string_literal: true

class Report::GroupContractHoldsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    prepare_meta_tags title: t(".title")
    @all_month_names = policy_scope(Bi::ContractHold, :group_resolve).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    end_of_month = Date.parse(@month_name).end_of_month
    @last_available_date = policy_scope(Bi::ContractHold, :group_resolve).where("date <= ?", end_of_month).order(date: :desc).first.date
    @company_short_names = policy_scope(Bi::ContractHold, :group_resolve).available_company_names(@last_available_date)
    @orgs_options = params[:orgs]
    @view_orgcode_sum = params[:view_orgcode_sum] == "true"

    data = policy_scope(Bi::ContractHold, :group_resolve)
      .where(date: @last_available_date)
      .where('ORG_ORDER.org_order is not null')
      .where("ORG_ORDER.org_type = '创意板块'")
      .order('ORG_ORDER.org_order DESC')

    data = if @view_orgcode_sum
      data.select("CONTRACT_HOLD.orgcode_sum orgcode, ORG_ORDER.org_order, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract")
      .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_HOLD.orgcode_sum")
      .group("CONTRACT_HOLD.orgcode_sum, ORG_ORDER.org_order")
    else
      data.select("CONTRACT_HOLD.orgcode, ORG_ORDER.org_order, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract")
      .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_HOLD.orgcode")
      .group("CONTRACT_HOLD.orgcode, ORG_ORDER.org_order")
    end

    all_company_orgcodes = data.collect(&:orgcode)
    @all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ["000103"] if @orgs_options.blank? # hide 天华节能

    data = if @view_orgcode_sum
      data.where(orgcode_sum: @orgs_options)
    else
      data.where(orgcode: @orgs_options)
    end

    @company_codes = data.collect(&:orgcode)
    @company_short_names = @company_codes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
    @organization_options = @all_company_short_names.zip(all_company_orgcodes)

    @biz_retent_contract = data.collect do |d|
      if d.present?
        (d.busiretentcontract.to_f / 10000.to_f).round(0)
      else
        0
      end
    end

    @biz_retent_no_contract = data.collect do |d|
      if d.present?
        (d.busiretentnocontract.to_f / 10000.to_f).round(0)
      else
        0
      end
    end

    @biz_retent_totals = @biz_retent_contract.zip(@biz_retent_no_contract).map { |d| d[0] + d[1] }

    this_month_staff_data = if end_of_month.year <= 2020 && end_of_month.month < 5
      Bi::StaffCount.staff_per_orgcode(end_of_month)
    else
      Bi::YearAvgStaff.worker_per_orgcode_by_date_and_sum(end_of_month, @view_orgcode_sum)
    end

    @group_avg_staff = @orgs_options.collect do |org_code|
      this_month_staff_data[org_code] || Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM
    end
    @biz_retent_totals_per_company = @biz_retent_totals.zip(@group_avg_staff).map do |d|
      (d[0] / d[1]).to_f.round(0) rescue 0
    end

    @biz_retent_totals_sum = @biz_retent_contract.sum()
    @sum_biz_retent_totals_staff = @biz_retent_totals.sum / @group_avg_staff.reject {|d| d == Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM}.sum.to_f

    @current_user_companies_short_names = current_user.user_company_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.group_contract_hold"),
        link: report_group_contract_hold_path(view_orgcode_sum: true) },
      { text: t("layouts.sidebar.operation.contract_hold", company: params[:company_name]&.strip || current_user.user_company_short_name),
        link: report_contract_hold_path(view_deptcode_sum: true) }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
