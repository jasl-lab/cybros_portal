# frozen_string_literal: true

class Report::SubsidiaryReceivesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }
  after_action :verify_authorized

  def show
    prepare_meta_tags title: t(".title")
    authorize Bi::SubCompanyRealReceive
    authorize Bi::SubCompanyNeedReceive
    @all_month_names = Bi::SubCompanyRealReceive.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_year = @end_of_month.beginning_of_year
    beginning_of_month = @end_of_month.beginning_of_month
    @orgs_options = params[:orgs]
    @view_orgcode_sum = params[:view_orgcode_sum] == "true"
    selected_short_name = params[:company_name]&.strip

    real_data = policy_scope(Bi::SubCompanyRealReceive, :group_resolve)
      .where(realdate: beginning_of_year..@end_of_month)
      .where('ORG_ORDER.org_order is not null')
      .where("ORG_ORDER.org_type = '创意板块'")
      .order('ORG_ORDER.org_order ASC')

    real_data = if @view_orgcode_sum
      real_data.select("orgcode_sum orgcode, org_order, SUM(IFNULL(total,0)) total, SUM(markettotal) markettotal")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_REAL_RECEIVE.orgcode_sum")
        .group(:orgcode_sum, :org_order)
    else
      real_data.select("orgcode, org_order, SUM(IFNULL(total,0)) total, SUM(markettotal) markettotal")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_REAL_RECEIVE.orgcode")
        .group(:orgcode, :org_order)
    end

    only_have_real_data_orgs = real_data.collect(&:orgcode)
    real_company_short_names = only_have_real_data_orgs.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
    @orgs_options = only_have_real_data_orgs if @orgs_options.blank?
    @organization_options = real_company_short_names.zip(only_have_real_data_orgs)

    @sum_org_names = @organization_options.reject { |k, v| !v.start_with?("H") }.collect(&:first)

    if selected_short_name.present?
      selected_sum_h_code = Bi::OrgShortName.org_code_by_short_name.fetch(selected_short_name, selected_short_name)
      @orgs_options = Bi::SubCompanyRealReceive.where(realdate: beginning_of_year..@end_of_month).where(orgcode_sum: selected_sum_h_code).pluck(:orgcode)
      if @orgs_options.blank?
        @orgs_options = Bi::SubCompanyRealReceive.where(realdate: beginning_of_year..@end_of_month).where(orgcode_sum: 'H'+selected_sum_h_code).pluck(:orgcode)
      end
    end

    real_data = if @view_orgcode_sum
      real_data.where(orgcode_sum: @orgs_options)
    else
      real_data.where(orgcode: @orgs_options)
    end

    @real_company_short_names = real_data.collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }
    @real_receives = real_data.collect { |d| ((d.total + d.markettotal) / 100_0000.0).round(0) }
    @fix_sum_real_receives = (policy_scope(Bi::SubCompanyRealReceive, :group_resolve).where(realdate: beginning_of_year..@end_of_month)
      .select("SUM(real_receive) fix_sum_real_receives").first.fix_sum_real_receives / 10000_0000.0).round(1)
    @fix_sum_market_totals = (policy_scope(Bi::SubCompanyRealReceive, :group_resolve).where(realdate: beginning_of_year..@end_of_month)
      .select("SUM(markettotal) fix_sum_markettotals").first.fix_sum_markettotals / 10000.0).round(1)

    need_data_last_available_date = policy_scope(Bi::SubCompanyNeedReceive, :group_resolve).last_available_date(@end_of_month)

    need_data = policy_scope(Bi::SubCompanyNeedReceive, :group_resolve)
      .where(date: need_data_last_available_date)
      .where('ORG_ORDER.org_order is not null')
      .where("ORG_ORDER.org_type = '创意板块'")
      .order('ORG_ORDER.org_order ASC')

    need_data = if @view_orgcode_sum
      need_data.select("orgcode_sum orgcode, org_order, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_NEED_RECEIVE.orgcode_sum")
        .group(:orgcode_sum, :org_order)
        .where(orgcode_sum: @orgs_options)
    else
      need_data.select("orgcode, org_order, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_NEED_RECEIVE.orgcode")
        .group(:orgcode, :org_order)
        .where(orgcode: @orgs_options)
    end

    @need_company_short_names = need_data.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c.orgcode, c.orgcode) }
    @need_long_account_receives = need_data.collect { |d| ((d.long_account_receive || 0) / 100_0000.0).round(0) }
    @need_short_account_receives = need_data.collect { |d| ((d.short_account_receive || 0) / 100_0000.0).round(0) }
    @need_should_receives = need_data.collect { |d| ((d.unsign_receive.to_f + d.sign_receive.to_f) / 100_0000.0).round(0) }

    fix_need_data = policy_scope(Bi::SubCompanyNeedReceive, :group_resolve).where(date: need_data_last_available_date)
      .select("SUM(account_longbill) long_account_receive, SUM(busi_unsign_receive)+SUM(busi_sign_receive) business_receive").first
    @fix_need_long_account_receives = (fix_need_data.long_account_receive / 100_0000.0).round(0)
    @fix_need_short_account_receives = (fix_need_data.business_receive / 100_0000.0).round(0)
    @fix_need_should_receives = @fix_need_long_account_receives + @fix_need_short_account_receives

    worker_per_orgcode = if @end_of_month.year <= 2020 && @end_of_month.month < 5
      Bi::StaffCount.staff_per_orgcode(@end_of_month)
    else
      Bi::YearAvgStaff.worker_per_orgcode_by_date_and_sum(@end_of_month, @view_orgcode_sum)
    end

    @real_receives_per_worker = real_data.collect do |d|
      staff_number = worker_per_orgcode.fetch(d.orgcode, Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM)
      staff_number = Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM if staff_number.zero?
      (d.total / (staff_number * 10000).to_f).round(0)
    end

    staff_per_orgcode = Bi::YearAvgStaffAll.staff_per_orgcode_by_date_and_sum(@end_of_month, @view_orgcode_sum)
    @real_receives_per_staff = real_data.collect do |d|
      staff_number = staff_per_orgcode.fetch(d.orgcode, Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM)
      staff_number = Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM if staff_number.zero?
      (d.total / (staff_number * 10000).to_f).round(0)
    end

    @real_receives_gap = @real_receives_per_worker.zip(@real_receives_per_staff).map { |d| d[0] - d[1] }

    @need_should_receives_per_staff = need_data.collect do |d|
      staff_number = worker_per_orgcode.fetch(d.orgcode, Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM)
      staff_number = Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM if staff_number.zero?
      (((d.long_account_receive || 0) + (d.short_account_receive || 0) + d.unsign_receive.to_f + d.sign_receive.to_f) / (staff_number * 10000.0).to_f).round(0)
    end

    complete_value_data = if current_user.roles.pluck(:report_view_all).any? || current_user.admin?
      Bi::CompleteValue.all
    else
      Bi::CompleteValue.where(orgcode: current_user.user_company_names)
    end.where(date: beginning_of_year..@end_of_month)
      .select("orgcode, SUM(IFNULL(total,0)) sum_total")
      .group(:orgcode)
    complete_value_hash = complete_value_data.reduce({}) do |h, d|
      short_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(d.orgcode, d.orgcode)
      h[short_name] = d.sum_total
      h
    end

    real_rate_sum = policy_scope(Bi::SubCompanyRealRateSum, :group_resolve)
      .where(date: beginning_of_month)
      .where('ORG_ORDER.org_order is not null')
      .where("ORG_ORDER.org_type = '创意板块'")
      .order('ORG_ORDER.org_order ASC')
    real_rate_sum = if @view_orgcode_sum
      real_rate_sum.select("orgcode_sum orgcode, org_order, SUM(IFNULL(sumvalue_change_nc,0)) sumvalue_change_nc, SUM(IFNULL(realamount_nc,0)) realamount_nc, SUM(IFNULL(trans_nc,0)) trans_nc, SUM(IFNULL(sumvalue_change_now,0)) sumvalue_change_now, SUM(IFNULL(realamount_now,0)) realamount_now, SUM(IFNULL(trans_now,0)) trans_now")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_REAL_RATE_SUM.orgcode_sum")
        .group(:orgcode_sum, :org_order)
        .where(orgcode_sum: @orgs_options)
    else
      real_rate_sum.select("orgcode, org_order, SUM(IFNULL(sumvalue_change_nc,0)) sumvalue_change_nc, SUM(IFNULL(realamount_nc,0)) realamount_nc, SUM(IFNULL(trans_nc,0)) trans_nc, SUM(IFNULL(sumvalue_change_now,0)) sumvalue_change_now, SUM(IFNULL(realamount_now,0)) realamount_now, SUM(IFNULL(trans_now,0)) trans_now")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_REAL_RATE_SUM.orgcode")
        .group(:orgcode, :org_order)
        .where(orgcode: @orgs_options)
    end

    @payback_rates = real_data.collect do |d|
      r = real_rate_sum.find { |r| r.orgcode == d.orgcode }
      if r.present?
        numerator = r.realamount_now - r.realamount_nc
        年初应收款 = r.sumvalue_change_nc - (r.realamount_nc)
        denominator = (年初应收款 < 0 ? 0 : 年初应收款) * (beginning_of_month.month / 12.0) + r.sumvalue_change_now - r.sumvalue_change_nc
        ((numerator / denominator.to_f)*100).round(1)
      else
        0
      end
    end
  end

  def need_receives_staff_drill_down
    authorize Bi::SubCompanyRealRateSum
    short_company_name = params[:company_name]
    @company_name = Bi::OrgShortName.company_long_names.fetch(short_company_name, short_company_name)
    company_code = Bi::OrgShortName.org_code_by_short_name.fetch(short_company_name, short_company_name)
    begin_month = Date.parse(params[:month_name]).beginning_of_month
    @data = (Bi::SubCompanyRealRate.where(orgcode: company_code)
      .or(Bi::SubCompanyRealRate.where(orgcode_sum: company_code))).where(date: begin_month)
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.subsidiary_receive"),
        link: report_subsidiary_receive_path(view_orgcode_sum: params[:view_orgcode_sum]) }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
