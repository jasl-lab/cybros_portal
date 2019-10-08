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
    @depts_options = params[:depts]
    @view_deptcode_sum = params[:view_deptcode_sum] == "true"

    @selected_short_name = params[:company_name]&.strip || current_user.user_company_short_name
    selected_orgcode = Bi::OrgShortName.org_code_by_short_name.fetch(@selected_short_name, @selected_short_name)
    selected_company_long_name = Bi::OrgShortName.company_long_names.fetch(@selected_short_name, @selected_short_name)
    selected_department_name = params[:department_name]&.strip

    real_data_last_available_date = policy_scope(Bi::CompleteValueDept).last_available_date(@end_of_month)
    real_data = policy_scope(Bi::SubCompanyRealReceive)
      .where(realdate: beginning_of_year..@end_of_month).where(orgcode: selected_orgcode)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", real_data_last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", real_data_last_available_date)

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

    only_have_real_data_depts = real_data.collect(&:deptcode)
    real_department_short_names = only_have_real_data_depts.collect { |d| Bi::OrgReportDeptOrder.department_names.fetch(d, Bi::PkCodeName.mapping2deptcode.fetch(d, d)) }
    @depts_options = only_have_real_data_depts if @depts_options.blank?
    @department_options = real_department_short_names.zip(only_have_real_data_depts)
    @sum_dept_names = @department_options.reject { |k, v| !v.start_with?("H") }.collect(&:first)


    if selected_department_name.present?
      @depts_options = Bi::OrgReportDeptOrder.dept_code_by_short_name(selected_company_long_name, real_data_last_available_date).where(上级部门: selected_department_name).pluck(:'编号')
    end

    real_data = if @view_deptcode_sum
      real_data.where(deptcode_sum: @depts_options)
    else
      real_data.where(deptcode: @depts_options)
    end

    @real_department_short_names = real_data.collect { |r| Bi::OrgReportDeptOrder.department_names.fetch(r.deptcode, Bi::PkCodeName.mapping2deptcode.fetch(r.deptcode, r.deptcode)) }
    @real_receives = real_data.collect { |d| (d.real_receive / 100_00.0).round(0) }
    @sum_real_receives = (@real_receives.sum / 10000.0).round(1)

    need_data_last_available_date = policy_scope(Bi::SubCompanyNeedReceive).last_available_date(@end_of_month)
    need_data = policy_scope(Bi::SubCompanyNeedReceive)
      .where(date: need_data_last_available_date).where(orgcode: selected_orgcode)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", need_data_last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", need_data_last_available_date)

    need_data = if @view_deptcode_sum
      need_data.select("deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
        .group(:"SUB_COMPANY_NEED_RECEIVE.deptcode_sum", :"ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
        .where(deptcode_sum: @depts_options)
    else
      need_data.select("deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_NEED_RECEIVE.deptcode")
        .group(:"SUB_COMPANY_NEED_RECEIVE.deptcode", :"ORG_REPORT_DEPT_ORDER.部门排名")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_NEED_RECEIVE.deptcode")
        .where(deptcode: @depts_options)
    end

    @need_company_short_names = need_data.collect { |c| Bi::OrgReportDeptOrder.department_names.fetch(c.deptcode, Bi::PkCodeName.mapping2deptcode.fetch(c.deptcode, c.deptcode)) }
    @need_long_account_receives = need_data.collect { |d| ((d.long_account_receive || 0) / 100_00.0).round(0) }
    @need_short_account_receives = need_data.collect { |d| ((d.short_account_receive || 0) / 100_00.0).round(0) }
    @need_should_receives = need_data.collect { |d| ((d.unsign_receive.to_f + d.sign_receive.to_f) / 100_00.0).round(0) }

    @sum_need_should_receives = @need_should_receives.sum
    @sum_need_long_account_receives = @need_long_account_receives.sum
    @sum_need_short_account_receives = @need_short_account_receives.sum

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

    complete_value_data = if @view_deptcode_sum
      Bi::CompleteValueDept.where(orgcode: selected_orgcode)
        .select("deptcode_sum deptcode, SUM(total) sum_total")
        .group(:deptcode_sum)
    else
      Bi::CompleteValueDept.where(orgcode: selected_orgcode)
        .select("deptcode, SUM(total) sum_total")
        .group(:deptcode)
    end.where(date: real_data_last_available_date)

    complete_value_hash = complete_value_data.reduce({}) do |h, d|
      dept_name = Bi::OrgReportDeptOrder.department_names.fetch(d.deptcode, Bi::PkCodeName.mapping2deptcode.fetch(d.deptcode, d.deptcode))
      h[dept_name] = d.sum_total
      h
    end
    @payback_rates = real_data.collect do |d|
      dept_name = Bi::OrgReportDeptOrder.department_names.fetch(d.deptcode, Bi::PkCodeName.mapping2deptcode.fetch(d.deptcode, d.deptcode))
      complete_value = complete_value_hash.fetch(dept_name, 100000)
      if complete_value % 1 == 0
        0
      else
        ((d.real_receive / complete_value.to_f) * 100).round(0)
      end
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
        link: report_subsidiary_department_receive_path(view_deptcode_sum: true) }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
