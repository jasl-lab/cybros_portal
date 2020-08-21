# frozen_string_literal: true

class Report::SubsidiaryDesignCashFlowsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = Bi::DeptMoneyFlow.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_year = @end_of_month.beginning_of_year
    @depts_options = params[:depts]
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'

    @selected_short_name = params[:company_name]&.strip || current_user.user_company_short_name

    available_company_orgcodes = policy_scope(Bi::DeptMoneyFlow)
        .where(checkdate: beginning_of_year..@end_of_month)
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = OCDW.V_TH_DEPTMONEYFLOW.comp")
        .where('ORG_ORDER.org_order is not null')
        .order('ORG_ORDER.org_order DESC').pluck(:comp).uniq
    @available_short_company_names = available_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

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
