# frozen_string_literal: true

class Report::SubsidiaryDepartmentReceivesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }
  after_action :verify_authorized

  def show
    authorize Bi::SubCompanyRealReceive
    @all_month_names = Bi::SubCompanyRealReceive.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_year = Date.parse(@month_name).beginning_of_year
    @view_deptcode_sum = params[:view_deptcode_sum] == "true"

    @selected_short_name = params[:company_name]&.strip || current_user.user_company_short_name
    selected_orgcode = Bi::OrgShortName.org_code_by_short_name.fetch(@selected_short_name, @selected_short_name)

    real_data = policy_scope(Bi::SubCompanyRealReceive)
      .where(realdate: beginning_of_year..@end_of_month).where(orgcode: selected_orgcode)

    real_data = if @view_deptcode_sum
      real_data.select("deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(real_receive) real_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_REAL_RECEIVE.deptcode_sum")
        .group(:"SUB_COMPANY_REAL_RECEIVE.deptcode_sum", :"ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_REAL_RECEIVE.deptcode_sum")
    else
      real_data.select("deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(real_receive) real_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_REAL_RECEIVE.deptcode")
        .group(:"SUB_COMPANY_REAL_RECEIVE.deptcode", :"ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_REAL_RECEIVE.deptcode")
    end

    @real_department_short_names = real_data.collect { |r| Bi::OrgReportDeptOrder.department_names.fetch(r.deptcode, r.deptcode) }
    @real_receives = real_data.collect { |d| (d.real_receive / 100_00.0).round(0) }

    need_data_last_available_date = policy_scope(Bi::SubCompanyNeedReceive).last_available_date(@end_of_month)
    need_data = policy_scope(Bi::SubCompanyNeedReceive)
      .where(date: need_data_last_available_date).where(orgcode: selected_orgcode)

    need_data = if @view_deptcode_sum
      need_data.select("deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
        .group(:"SUB_COMPANY_NEED_RECEIVE.deptcode_sum", :"ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
    else
      need_data.select("deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_NEED_RECEIVE.deptcode")
        .group(:"SUB_COMPANY_NEED_RECEIVE.deptcode", :"ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_NEED_RECEIVE.deptcode")
    end
    @need_company_short_names = need_data.collect { |c| Bi::OrgReportDeptOrder.department_names.fetch(c.deptcode, c.deptcode) }
    @need_long_account_receives = need_data.collect { |d| ((d.long_account_receive || 0) / 100_00.0).round(0) }
    @need_short_account_receives = need_data.collect { |d| ((d.short_account_receive || 0) / 100_00.0).round(0) }
    @need_should_receives = need_data.collect { |d| ((d.unsign_receive.to_f + d.sign_receive.to_f) / 100_00.0).round(0) }

    staff_per_dept_code = if selected_orgcode == "000101"
      Bi::ShStaffCount.staff_per_dept_code_by_date(@end_of_month)
    else
      Bi::YearAvgStaff.staff_per_dept_code_by_date(selected_orgcode, @end_of_month)
    end
    @real_receives_per_staff = real_data.collect do |d|
      staff_number = staff_per_dept_code.fetch(d.deptcode, 1000_0000)
      (d.real_receive / (staff_number * 10000).to_f).round(0)
    end
    @need_should_receives_per_staff = need_data.collect do |d|
      staff_number = staff_per_dept_code.fetch(d.deptcode, 1000_0000)
      (((d.long_account_receive || 0) + (d.short_account_receive || 0) + d.unsign_receive.to_f + d.sign_receive.to_f) / (staff_number * 10000.0).to_f).round(0)
    end
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
