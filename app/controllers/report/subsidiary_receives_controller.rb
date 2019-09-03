# frozen_string_literal: true

class Report::SubsidiaryReceivesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
    authorize Bi::SubCompanyRealReceive
    authorize Bi::SubCompanyNeedReceive
    @all_month_names = Bi::SubCompanyRealReceive.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    @orgs_options = params[:orgs]

    current_user_companies = current_user.user_company_names
    real_data = policy_scope(Bi::SubCompanyRealReceive).where("realdate <= ?", @end_of_month)
      .select("orgcode, org_order, SUM(real_receive) real_receive")
      .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_REAL_RECEIVE.orgcode")
      .group(:orgcode, :org_order)
      .order("ORG_ORDER.org_order DESC")
    @only_have_real_data_orgs = real_data.collect(&:orgcode)
    @real_company_names = @only_have_real_data_orgs.collect do |orgcode|
      Bi::PkCodeName.mapping2orgcode.fetch(orgcode, orgcode)
    end

    real_company_short_names = @real_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    @orgs_options = real_data.where.not(orgcode: "000101").pluck(:orgcode) if @orgs_options.blank?
    @organization_options = real_company_short_names.zip(@only_have_real_data_orgs)

    @real_data = real_data.where(orgcode: @orgs_options)
    @real_company_short_names = @real_data.collect { |r| Bi::StaffCount.company_short_names_by_orgcode(@end_of_month).fetch(r.orgcode, r.orgcode) }
    @real_receives = @real_data.collect { |d| (d.real_receive / 10000.0).round(0) }

    @need_data = policy_scope(Bi::SubCompanyNeedReceive) \
      # should add .where('date <= ?', @end_of_month), but date is refresh date
      .select("orgcode, org_order, SUM(busi_unsign_receive) unsign_receive, SUM(busi_sign_receive) sign_receive, SUM(account_longbill) long_account_receive, SUM(account_shortbill) short_account_receive")
      .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SUB_COMPANY_NEED_RECEIVE.orgcode")
      .group(:orgcode, :org_order)
      .order("ORG_ORDER.org_order DESC")
      .where(orgcode: @orgs_options)
    @need_company_names = @need_data.collect do |nd|
      Bi::PkCodeName.mapping2orgcode.fetch(nd.orgcode, nd.orgcode)
    end
    @need_company_short_names = @need_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
    @need_long_account_receives = @need_data.collect { |d| ((d.long_account_receive || 0) / 10000.0).round(0) }
    @need_short_account_receives = @need_data.collect { |d| ((d.short_account_receive || 0) / 10000.0).round(0) }
    @need_should_receives = @need_data.collect { |d| ((d.unsign_receive.to_f + d.sign_receive.to_f) / 10000.0).round(0) }

    @staff_per_company = Bi::StaffCount.staff_per_short_company_name(@end_of_month)
    @real_receives_per_staff = @real_data.collect do |d|
      company_name = Bi::PkCodeName.mapping2orgcode.fetch(d.orgcode, d.orgcode)
      short_name = Bi::StaffCount.company_short_names.fetch(company_name, company_name)
      staff_number = @staff_per_company.fetch(short_name, 10000)
      (d.real_receive / (staff_number * 10000).to_f).round(0)
    end
    @need_should_receives_per_staff = @need_data.collect do |d|
      company_name = Bi::PkCodeName.mapping2orgcode.fetch(d.orgcode, d.orgcode)
      short_name = Bi::StaffCount.company_short_names.fetch(company_name, company_name)
      staff_number = @staff_per_company.fetch(short_name, 10000)
      ((d.unsign_receive.to_f + d.sign_receive.to_f) / (staff_number * 10000.0).to_f).round(0)
    end

    complete_value_data = if current_user_companies.include?("上海天华建筑设计有限公司")
      Bi::CompleteValue.all
    else
      Bi::CompleteValue.where(orgcode: current_user_companies)
    end.where("date <= ?", @end_of_month)
      .select("orgcode, SUM(total) sum_total")
      .group(:orgcode)
    complete_value_hash = complete_value_data.reduce({}) do |h, d|
      company_name = Bi::PkCodeName.mapping2orgcode.fetch(d.orgcode, d.orgcode)
      short_name = Bi::StaffCount.company_short_names.fetch(company_name, company_name)
      h[short_name] = d.sum_total
      h
    end
    @payback_rates = @real_data.collect do |d|
      company_name = Bi::PkCodeName.mapping2orgcode.fetch(d.orgcode, d.orgcode)
      short_name = Bi::StaffCount.company_short_names.fetch(company_name, company_name)
      complete_value = complete_value_hash.fetch(short_name, 100000)
      ((d.real_receive / complete_value.to_f) * 100).round(0)
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
        link: report_subsidiary_receive_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
