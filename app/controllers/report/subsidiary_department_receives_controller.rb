# frozen_string_literal: true

class Report::SubsidiaryDepartmentReceivesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
    authorize Bi::SubCompanyRealReceive
    @all_month_names = Bi::SubCompanyRealReceive.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_year = Date.parse(@month_name).beginning_of_year
    @selected_short_name = params[:company_name]&.strip || current_user.user_company_short_name
    selected_orgcode = Bi::OrgShortName.org_code_by_short_name.fetch(@selected_short_name, @selected_short_name)
    data = Bi::SubCompanyRealReceive.where(realdate: beginning_of_year..@end_of_month).where(orgcode: selected_orgcode)
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.subsidiary_receive"),
        link: report_subsidiary_receive_path },
      { text: t("layouts.sidebar.operation.subsidiary_department_receive", company: params[:company_name]&.strip || current_user.user_company_short_name),
        link: report_subsidiary_department_receive_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
