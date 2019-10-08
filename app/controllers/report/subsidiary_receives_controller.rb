# frozen_string_literal: true

class Report::SubsidiaryReceivesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }
  after_action :verify_authorized

  def show
    authorize Bi::SubCompanyRealReceive
    authorize Bi::SubCompanyNeedReceive
    @all_month_names = Bi::SubCompanyRealReceive.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_year = Date.parse(@month_name).beginning_of_year
    @orgs_options = params[:orgs]
    @view_orgcode_sum = params[:view_orgcode_sum] == "true"
    selected_short_name = params[:company_name]&.strip

    current_user_companies = current_user.user_company_names
    real_data = policy_scope(Bi::SubCompanyRealReceive).where(realdate: beginning_of_year..@end_of_month)
      .order("ORG_ORDER.org_order DESC")

    real_data = if @view_orgcode_sum
      real_data.select("orgcode_sum orgcode, org_order, SUM(real_receive) real_receive")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_REAL_RECEIVE.orgcode_sum")
        .group(:orgcode_sum, :org_order)
    else
      real_data.select("orgcode, org_order, SUM(real_receive) real_receive")
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
    end

    real_data = if @view_orgcode_sum
      real_data.where(orgcode_sum: @orgs_options)
    else
      real_data.where(orgcode: @orgs_options)
    end

    @real_company_short_names = real_data.collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }
    @real_receives = real_data.collect { |d| (d.real_receive / 100_0000.0).round(0) }
    @fix_sum_real_receives = (policy_scope(Bi::SubCompanyRealReceive).where(realdate: beginning_of_year..@end_of_month)
      .select("SUM(real_receive) fix_sum_real_receives").first.fix_sum_real_receives / 10000_0000.0).round(1)

    need_data_last_available_date = policy_scope(Bi::SubCompanyNeedReceive).last_available_date(@end_of_month)

    need_data = policy_scope(Bi::SubCompanyNeedReceive)
      .where(date: need_data_last_available_date)
      .order("ORG_ORDER.org_order DESC")

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

    fix_need_data = policy_scope(Bi::SubCompanyNeedReceive).where(date: need_data_last_available_date)
      .select("SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive").first
    @fix_need_long_account_receives = (fix_need_data.long_account_receive / 100_0000.0).round(0)
    @fix_need_short_account_receives = (fix_need_data.short_account_receive / 100_0000.0).round(0)
    @fix_need_should_receives = @fix_need_long_account_receives + @fix_need_short_account_receives

    staff_per_company = Bi::StaffCount.staff_per_short_company_name(@end_of_month)
    @real_receives_per_staff = real_data.collect do |d|
      short_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(d.orgcode, d.orgcode)
      staff_number = staff_per_company.fetch(short_name, 1000_0000)
      (d.real_receive / (staff_number * 10000).to_f).round(0)
    end
    @need_should_receives_per_staff = need_data.collect do |d|
      short_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(d.orgcode, d.orgcode)
      staff_number = staff_per_company.fetch(short_name, 1000_0000)
      (((d.long_account_receive || 0) + (d.short_account_receive || 0) + d.unsign_receive.to_f + d.sign_receive.to_f) / (staff_number * 10000.0).to_f).round(0)
    end

    complete_value_data = if current_user_companies.include?("上海天华建筑设计有限公司")
      Bi::CompleteValue.all
    else
      Bi::CompleteValue.where(orgcode: current_user_companies)
    end.where(date: beginning_of_year..@end_of_month)
      .select("orgcode, SUM(total) sum_total")
      .group(:orgcode)
    complete_value_hash = complete_value_data.reduce({}) do |h, d|
      short_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(d.orgcode, d.orgcode)
      h[short_name] = d.sum_total
      h
    end
    @payback_rates = real_data.collect do |d|
      short_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(d.orgcode, d.orgcode)
      complete_value = complete_value_hash.fetch(short_name, 100000)
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
        link: report_subsidiary_receive_path(view_orgcode_sum: params[:view_orgcode_sum]) }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
