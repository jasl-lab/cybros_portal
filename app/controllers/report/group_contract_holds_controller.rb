# frozen_string_literal: true

class Report::GroupContractHoldsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    @all_month_names = policy_scope(Bi::ContractHold).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    end_of_month = Date.parse(@month_name).end_of_month
    @last_available_date = policy_scope(Bi::ContractHold).where("date <= ?", end_of_month).order(date: :desc).first.date
    @company_short_names = policy_scope(Bi::ContractHold).available_company_names(@last_available_date)

    data = policy_scope(Bi::ContractHold)
      .where(date: @last_available_date)
      .select("CONTRACT_HOLD.orgcode, ORG_ORDER.org_order, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract")
      .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_HOLD.orgcode")
      .group("CONTRACT_HOLD.orgcode, ORG_ORDER.org_order")
      .order("ORG_ORDER.org_order DESC")

    all_company_orgcodes = data.collect(&:orgcode)
    @all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ["000103"] if @orgs_options.blank? # hide 天华节能

    @biz_retent_contract = @orgs_options.collect do |org_code|
      d = data.find { |c| c.orgcode == org_code }
      if d.present?
        (d.busiretentcontract.to_f / 10000.to_f).round(0)
      else
        0
      end
    end

    @biz_retent_no_contract = @orgs_options.collect do |org_code|
      d = data.find { |c| c.orgcode == org_code }
      if d.present?
        (d.busiretentnocontract.to_f / 10000.to_f).round(0)
      else
        0
      end
    end

    @biz_retent_totals = @biz_retent_contract.zip(@biz_retent_no_contract).map { |d| d[0] + d[1] }

    this_month_staff_data = Bi::StaffCount.staff_per_orgcode(@end_of_month)

    @group_avg_staff = @orgs_options.collect do |org_code|
      this_month_staff_data[org_code] || Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM
    end
    @biz_retent_totals_per_company = @biz_retent_totals.zip(@group_avg_staff).map do |d|
      (d[0] / d[1]).to_f.round(0) rescue 0
    end

    @biz_retent_totals_sum = @biz_retent_contract.sum()
    @sum_biz_retent_totals_staff = @biz_retent_totals.sum / @group_avg_staff.reject {|d| d == Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM}.sum.to_f
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.group_contract_hold"),
        link: report_group_contract_hold_path },
      { text: t("layouts.sidebar.operation.contract_hold", company: params[:company_name]&.strip || current_user.user_company_short_name),
        link: report_contract_hold_path(view_deptcode_sum: true) }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
