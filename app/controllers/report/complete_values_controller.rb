# frozen_string_literal: true

class Report::CompleteValuesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
    authorize Bi::CompleteValue
    @all_month_names = Bi::CompleteValue.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month
    @orgs_options = params[:orgs]
    @view_orgcode_sum = params[:view_orgcode_sum] == "true"
    @selected_short_name = params[:company_name]&.strip

    last_available_date = policy_scope(Bi::CompleteValue).last_available_date(@end_of_month)
    data = policy_scope(Bi::CompleteValue).where(date: last_available_date)
      .having("SUM(total) > 0")
      .order("ORG_ORDER.org_order DESC")

    data = if @view_orgcode_sum
      data.select("orgcode_sum orgcode, org_order, SUM(total) sum_total")
        .group(:orgcode_sum, :org_order)
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = COMPLETE_VALUE.orgcode_sum")
    else
      data.select("orgcode, org_order, SUM(total) sum_total")
        .group(:orgcode, :org_order)
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = COMPLETE_VALUE.orgcode")
    end

    all_company_orgcodes = data.collect(&:orgcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ["000101"] if @orgs_options.blank?
    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @sum_org_names = @organization_options.reject { |k, v| !v.start_with?("H") }.collect(&:first)

    if @selected_short_name.present?
      selected_sum_h_code = Bi::OrgShortName.org_code_by_short_name.fetch(@selected_short_name, @selected_short_name)
      @orgs_options = Bi::CompleteValue.where(orgcode_sum: selected_sum_h_code).pluck(:orgcode)
    end

    data = if @view_orgcode_sum
      data.where(orgcode_sum: @orgs_options)
    else
      data.where(orgcode: @orgs_options)
    end
    @company_short_names = data.collect(&:orgcode).collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
    @complete_value_totals = data.collect { |d| (d.sum_total / 100_0000.0).round(0) }
    @fix_sum_complete_value_totals = ((Bi::CompleteValue.where(date: last_available_date).select("SUM(total) sum_total").first.sum_total || 0) / 10000_0000.0).round(1)
    @complete_value_year_totals = @complete_value_totals.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
    @complete_value_year_totals_remain = @complete_value_year_totals.zip(@complete_value_totals).map { |d| d[0] - d[1] }
    @fix_sum_complete_value_year_totals = (@complete_value_year_totals.sum / 100.0).round(1)
    @staff_per_company = Bi::StaffCount.staff_per_short_company_name(@end_of_month)
    @complete_value_totals_per_staff = data.collect do |d|
      company_name = Bi::OrgShortName.company_long_names_by_orgcode.fetch(d.orgcode, d.orgcode)
      short_name = Bi::OrgShortName.company_short_names.fetch(company_name, company_name)
      staff_number = @staff_per_company.fetch(short_name, 1000_0000)
      (d.sum_total / (staff_number * 10000).to_f).round(0)
    end
    sum_of_complete_value_totals_per_staff = @complete_value_totals_per_staff.sum.to_f
    @fix_avg_complete_value_totals_per_staff = if sum_of_complete_value_totals_per_staff % 1 == 0
      0
    else
      (sum_of_complete_value_totals_per_staff / @complete_value_totals_per_staff.size).round(0)
    end
    @complete_value_year_totals_per_staff = @complete_value_totals_per_staff.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
    sum_of_complete_value_year_totals_per_staff = @complete_value_year_totals_per_staff.sum.to_f
    @fix_avg_complete_value_year_totals_per_staff = if sum_of_complete_value_year_totals_per_staff % 1 == 0
      0
    else
      (sum_of_complete_value_year_totals_per_staff / @complete_value_year_totals_per_staff.size).round(0)
    end
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.complete_value"),
        link: report_complete_value_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
