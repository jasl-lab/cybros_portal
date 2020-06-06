# frozen_string_literal: true

class Report::SubsidiaryDepartmentReceivesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, only: %i[show], if: -> { params[:in_iframe].present? }
  after_action :verify_authorized

  def show
    authorize Bi::SubCompanyRealReceive
    @all_month_names = Bi::SubCompanyNeedReceive.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_month = Date.parse(@month_name).beginning_of_month
    beginning_of_year = Date.parse(@month_name).beginning_of_year
    @real_receive_per_staff_ref = params[:real_receive_per_staff_ref] || 60
    @depts_options = params[:depts]
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'

    @selected_short_name = params[:company_name]&.strip || current_user.user_company_short_name
    selected_orgcode = Bi::OrgShortName.org_code_by_short_name.fetch(@selected_short_name, @selected_short_name)
    selected_company_long_name = Bi::OrgShortName.company_long_names.fetch(@selected_short_name, @selected_short_name)
    selected_department_name = params[:department_name]&.strip

    @real_data_last_available_date = policy_scope(Bi::CompleteValueDept).last_available_date(@end_of_month)
    real_data = policy_scope(Bi::SubCompanyRealReceive)
      .where(realdate: beginning_of_year..@end_of_month)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", @real_data_last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", @real_data_last_available_date)

    real_data = if @view_deptcode_sum
      real_data.where(orgcode_sum: ['H' + selected_orgcode, selected_orgcode])
        .select("deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(IFNULL(total,0)) total, SUM(markettotal) markettotal")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_REAL_RECEIVE.deptcode_sum")
        .group(:"ORG_REPORT_DEPT_ORDER.部门排名", :"SUB_COMPANY_REAL_RECEIVE.deptcode_sum")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_REAL_RECEIVE.deptcode_sum")
    else
      real_data.where(orgcode: selected_orgcode)
        .select("deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(IFNULL(total,0)) total, SUM(markettotal) markettotal")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_REAL_RECEIVE.deptcode")
        .group(:"ORG_REPORT_DEPT_ORDER.部门排名", :"SUB_COMPANY_REAL_RECEIVE.deptcode")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_REAL_RECEIVE.deptcode")
    end

    only_have_real_data_depts = real_data.collect(&:deptcode)
    real_department_short_names = only_have_real_data_depts.collect { |d| Bi::OrgReportDeptOrder.department_names(@real_data_last_available_date).fetch(d, Bi::PkCodeName.mapping2deptcode.fetch(d, d)) }
    @depts_options = only_have_real_data_depts if @depts_options.blank?
    @department_options = real_department_short_names.zip(only_have_real_data_depts)
    @sum_dept_names = @department_options.reject { |k, v| !v.start_with?("H") }.collect(&:first)


    if selected_department_name.present?
      @depts_options = Bi::OrgReportDeptOrder.dept_code_by_short_name(selected_company_long_name, @real_data_last_available_date).where(上级部门: selected_department_name).pluck(:'编号')
    end

    real_data = if @view_deptcode_sum
      real_data.where(deptcode_sum: @depts_options)
    else
      real_data.where(deptcode: @depts_options)
    end

    @real_department_short_codes = real_data.collect(&:deptcode)
    @real_department_short_names = @real_department_short_codes.collect { |c| Bi::OrgReportDeptOrder.department_names(@real_data_last_available_date).fetch(c, Bi::PkCodeName.mapping2deptcode.fetch(c, c)) }
    @real_receives = real_data.collect { |d| (d.total / 100_00.0).round(0) }
    true_real_meta_receives = policy_scope(Bi::SubCompanyRealReceive)
      .where(realdate: beginning_of_year..@end_of_month)
      .where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", @real_data_last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", @real_data_last_available_date)
      .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_REAL_RECEIVE.deptcode_sum")

    true_real_meta_receives = if @view_deptcode_sum
      true_real_meta_receives.where(orgcode_sum: ['H' + selected_orgcode, selected_orgcode])
    else
      true_real_meta_receives.where(orgcode: selected_orgcode)
    end

    true_real_receives = true_real_meta_receives
      .select("SUM(IFNULL(total,0)) total")
      .collect { |d| (d.total.to_f / 100_00.0).round(0) }

    @sum_real_receives = (true_real_receives.sum / 10000.0).round(1)

    true_real_markettotals = true_real_meta_receives
      .select("SUM(markettotal) markettotal")
      .collect { |d| (d.markettotal.to_f / 100_00.0).round(0) }
    @sum_real_markettotals = true_real_markettotals.sum.round(1)


    need_data_last_available_date = policy_scope(Bi::SubCompanyNeedReceive).last_available_date(@end_of_month)
    need_data = policy_scope(Bi::SubCompanyNeedReceive)
      .where(date: need_data_last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", need_data_last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", need_data_last_available_date)

    need_data = if @view_deptcode_sum
      need_data.where(orgcode_sum: ['H' + selected_orgcode, selected_orgcode])
        .select("deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
        .group(:"ORG_REPORT_DEPT_ORDER.部门排名", :"SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
    else
      need_data.where(orgcode: selected_orgcode)
        .select("deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SUB_COMPANY_NEED_RECEIVE.deptcode")
        .group(:"ORG_REPORT_DEPT_ORDER.部门排名", :"SUB_COMPANY_NEED_RECEIVE.deptcode")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SUB_COMPANY_NEED_RECEIVE.deptcode")
    end

    need_data = if @view_deptcode_sum && @depts_options.present?
      need_data.where(deptcode_sum: @depts_options)
    elsif @depts_options.present?
      need_data.where(deptcode: @depts_options)
    else
      need_data
    end

    @need_dept_codes = need_data.collect(&:deptcode)
    @need_company_short_names = @need_dept_codes.collect { |c| Bi::OrgReportDeptOrder.department_names(need_data_last_available_date).fetch(c, Bi::PkCodeName.mapping2deptcode.fetch(c, c)) }
    @need_long_account_receives = need_data.collect { |d| ((d.long_account_receive || 0) / 100_00.0).round(0) }
    @need_short_account_receives = need_data.collect { |d| ((d.short_account_receive || 0) / 100_00.0).round(0) }
    @need_should_receives = need_data.collect { |d| ((d.unsign_receive.to_f + d.sign_receive.to_f) / 100_00.0).round(0) }

    sum_need_total = policy_scope(Bi::SubCompanyNeedReceive)
      .select("SUM(account_need_receive) account_need_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
      .where(date: need_data_last_available_date).where(orgcode: selected_orgcode)
    @sum_need_should_receives = sum_need_total
      .collect { |d| ((d.account_need_receive || 0) / 100_00.0).round(0) }.first
    @sum_need_long_account_receives = sum_need_total
      .collect { |d| ((d.long_account_receive || 0) / 100_00.0).round(0) }.first
    @sum_need_short_account_receives = sum_need_total
      .collect { |d| ((d.short_account_receive || 0) / 100_00.0).round(0) }.first

    staff_per_dept_code = if selected_orgcode == '000101' && @end_of_month.year <= 2020 && @end_of_month.month < 5
      Bi::ShStaffCount.staff_per_dept_code_by_date(@end_of_month)
    else
      Bi::YearAvgStaff.staff_per_dept_code_by_date_and_sum(selected_orgcode, @end_of_month, @view_deptcode_sum)
    end
    real_total_staff_num = 0
    @real_receives_per_staff = real_data.collect do |d|
      staff_number = staff_per_dept_code.fetch(d.deptcode, Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM)
      real_total_staff_num += staff_number unless staff_number.to_i == Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM
      (d.total / (staff_number * 10000).to_f).round(0)
    end
    @avg_of_real_receives_per_staff = (@real_receives.sum.to_f / real_total_staff_num).round(1)
    need_total_staff_num = 0
    total_should_receives_per_staff = 0
    @need_should_receives_per_staff = need_data.collect do |d|
      staff_number = staff_per_dept_code.fetch(d.deptcode, Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM)
      need_total_staff_num += staff_number unless staff_number.to_i == Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM
      should_receives_per_staff = ((d.long_account_receive || 0) + (d.short_account_receive || 0) + d.unsign_receive.to_f + d.sign_receive.to_f) / 10000.0
      total_should_receives_per_staff += should_receives_per_staff
      (should_receives_per_staff / staff_number.to_f).round(0)
    end
    @need_should_receives_per_staff_max = @need_should_receives_per_staff.max&.round(-1) || 1
    @avg_of_need_should_receives_per_staff = if need_total_staff_num.zero?
      0
    else
      (total_should_receives_per_staff / need_total_staff_num).round(1)
    end

    previous_year_need_receive_data = policy_scope(Bi::SubCompanyNeedReceive)
      .where(date: (@end_of_month.beginning_of_year - 1.day))

    previous_year_need_receive_data = if @view_deptcode_sum
      previous_year_need_receive_data
        .select("deptcode_sum deptcode, SUM(account_need_receive) account_need_receive")
        .group(:"SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
        .order("SUB_COMPANY_NEED_RECEIVE.deptcode_sum")
    else
      previous_year_need_receive_data
        .select("deptcode, SUM(account_need_receive) account_need_receive")
        .group(:"SUB_COMPANY_NEED_RECEIVE.deptcode")
        .order("SUB_COMPANY_NEED_RECEIVE.deptcode")
    end

    previous_year_need_receive_hash = previous_year_need_receive_data.reduce({}) do |h, d|
      dept_name = Bi::OrgReportDeptOrder.department_names(@real_data_last_available_date).fetch(d.deptcode, Bi::PkCodeName.mapping2deptcode.fetch(d.deptcode, d.deptcode))
      h[dept_name] = d.account_need_receive
      h
    end

    complete_value_data = if @view_deptcode_sum
      Bi::CompleteValueDept.where(orgcode: ['H' + selected_orgcode, selected_orgcode])
        .select("deptcode_sum deptcode, SUM(IFNULL(total,0)) sum_total")
        .group(:deptcode_sum)
    else
      Bi::CompleteValueDept.where(orgcode: selected_orgcode)
        .select("deptcode, SUM(IFNULL(total,0)) sum_total")
        .group(:deptcode)
    end.where(date: @real_data_last_available_date)

    complete_value_hash = complete_value_data.reduce({}) do |h, d|
      dept_name = Bi::OrgReportDeptOrder.department_names(@real_data_last_available_date).fetch(d.deptcode, Bi::PkCodeName.mapping2deptcode.fetch(d.deptcode, d.deptcode))
      h[dept_name] = d.sum_total
      h
    end
    sum_real_receives_for_payback = 0
    sum_need_receives_for_payback = 0
    total_complete_value_per_staff = 0

    real_rate_sum = policy_scope(Bi::SubCompanyRealRateSum)
      .where(date: beginning_of_month)

    real_rate_sum = if @view_deptcode_sum
      real_rate_sum.select("deptcode_sum deptcode, SUM(IFNULL(sumvalue_change_nc,0)) sumvalue_change_nc, SUM(IFNULL(realamount_nc,0)) realamount_nc, SUM(IFNULL(trans_nc,0)) trans_nc, SUM(IFNULL(sumvalue_change_now,0)) sumvalue_change_now, SUM(IFNULL(realamount_now,0)) realamount_now, SUM(IFNULL(trans_now,0)) trans_now")
        .group(:deptcode_sum)
        .where(orgcode_sum: ['H' + selected_orgcode, selected_orgcode])
    else
      real_rate_sum.select("deptcode, SUM(IFNULL(sumvalue_change_nc,0)) sumvalue_change_nc, SUM(IFNULL(realamount_nc,0)) realamount_nc, SUM(IFNULL(trans_nc,0)) trans_nc, SUM(IFNULL(sumvalue_change_now,0)) sumvalue_change_now, SUM(IFNULL(realamount_now,0)) realamount_now, SUM(IFNULL(trans_now,0)) trans_now")
        .group(:deptcode)
        .where(orgcode: selected_orgcode)
    end

    @payback_rates = real_data.collect do |d|
      r = real_rate_sum.find { |r| r.deptcode == d.deptcode }
      if r.present?
        分子 = r.realamount_now + r.trans_now - r.realamount_nc - r.trans_nc
        年初应收款 = r.sumvalue_change_nc - r.realamount_nc
        分母 = 年初应收款 * (beginning_of_month.month / 12.0) + r.sumvalue_change_now - r.sumvalue_change_nc
        res = (分子 / 分母.to_f)*100
        (res> 100 ? 100 : res).round(0)
      else
        0
      end
    end
  end

  def need_receives_pay_rates_drill_down
    authorize Bi::SubCompanyRealRateSum
    short_company_name = params[:company_name]
    @department_name = params[:department_name]
    department_codes = [params[:department_code].strip]
    @company_name = Bi::OrgShortName.company_long_names.fetch(short_company_name, short_company_name)
    company_code = Bi::OrgShortName.org_code_by_short_name.fetch(short_company_name, short_company_name)
    @begin_month = Date.parse(params[:month_name]).beginning_of_month

    belong_deparments = Bi::OrgReportDeptOrder.where(组织: @company_name, 上级部门编号: department_codes)
    department_codes = if belong_deparments.exists?
      belong_deparments.pluck(:编号).reject { |dept_name| dept_name.include?('撤销') }
    else
      department_codes
    end

    @data = (Bi::SubCompanyRealRate.where(orgcode: company_code)
        .or(Bi::SubCompanyRealRate.where(orgcode_sum: company_code)))
      .where(date: @begin_month, deptcode: department_codes)
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
      { text: t("layouts.sidebar.operation.subsidiary_department_receive"),
        link: report_subsidiary_department_receive_path(view_deptcode_sum: true) }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
