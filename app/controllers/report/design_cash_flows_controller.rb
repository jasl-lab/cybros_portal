# frozen_string_literal: true

class Report::DesignCashFlowsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t(".title")
    @all_month_names = Bi::DeptMoneyFlow.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_month = @end_of_month.beginning_of_month
    @orgs_options = params[:orgs]

    orgs_data = policy_scope(Bi::DeptMoneyFlow)
      .select('OCDW.V_TH_DEPTMONEYFLOW.comp')
      .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = OCDW.V_TH_DEPTMONEYFLOW.comp')
      .where(checkdate: beginning_of_month..@end_of_month)
      .where('ORG_ORDER.org_order is not null')
      .order('ORG_ORDER.org_order DESC')

    only_have_data_orgs = orgs_data.pluck(:comp).uniq
    real_company_short_names = only_have_data_orgs.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
    @orgs_options = only_have_data_orgs if @orgs_options.blank?
    @organization_options = real_company_short_names.zip(only_have_data_orgs)

  end

  protected

  def set_page_layout_data
    @_sidebar_name = "operation"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.operation.header"),
      link: report_operation_path }]
  end
end
