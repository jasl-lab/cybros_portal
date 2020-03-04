# frozen_string_literal: true

class Report::YearlySubsidiaryCompleteValuesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::CompleteValue
    all_orgcodes = policy_scope(Bi::CompleteValue).distinct.pluck(:orgcode)
    all_company_names = all_orgcodes.collect do |c|
      Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c)
    end
    @all_short_companies = all_company_names.zip(all_orgcodes)

    all_month_names = policy_scope(Bi::CompleteValue).all_month_names
    end_of_month = Date.parse(all_month_names.first).end_of_month
    last_available_date = policy_scope(Bi::CompleteValue).last_available_date(end_of_month)

    data = policy_scope(Bi::CompleteValue).where(orgcode: @selected_org_code)
      .where(date: last_available_date)

    data = data.select("COMPLETE_VALUE.month, SUM(total) sum_total")
        .group("COMPLETE_VALUE.month")
        .order("COMPLETE_VALUE.month")

    @all_months = data.collect(&:month)
    @complete_value_totals = data.collect { |d| (d.sum_total / 10000.0).round(0) }
    @complete_value_ref = params[:complete_value_ref] || 9000
  end

  private

    def set_breadcrumbs
      current_company = current_user.user_company_names.first
      @selected_org_code = params[:org_code]&.strip || current_user.user_company_orgcode
      @selected_company_short_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(@selected_org_code, @selected_org_code)
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.yearly_subsidiary_complete_value", company: @selected_company_short_name),
        link: report_yearly_subsidiary_complete_value_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
