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
    @show_shanghai_hq = params[:show_shanghai_hq]&.presence
    @view_orgcode_sum = params[:view_orgcode_sum] == "true"

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

    all_company_names = data.collect(&:orgcode).collect do |c|
      Bi::PkCodeName.mapping2orgcode.fetch(c, c)
    end
    @all_company_short_names = all_company_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @complete_value_totals = data.collect { |d| (d.sum_total / 100_0000.0).round(0) }
    @fix_sum_complete_value_totals = ((Bi::CompleteValue.where(date: last_available_date).select("SUM(total) sum_total").first.sum_total || 0) / 10000_0000.0).round(1)
    @complete_value_year_totals = @complete_value_totals.collect { |d| (d / (@end_of_month.month / 12.0)).round(0) }
    @complete_value_year_totals_remain = @complete_value_year_totals.zip(@complete_value_totals).map { |d| d[0] - d[1] }
    @fix_sum_complete_value_year_totals = (@complete_value_year_totals.sum / 100.0).round(1)
    @staff_per_company = Bi::StaffCount.staff_per_short_company_name(@end_of_month)
    @complete_value_totals_per_staff = data.collect do |d|
      company_name = Bi::PkCodeName.mapping2orgcode.fetch(d.orgcode, d.orgcode)
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
    unless @show_shanghai_hq
      @all_company_short_names = @all_company_short_names[1..]
      @complete_value_totals = @complete_value_totals[1..]
      @complete_value_year_totals = @complete_value_year_totals[1..]
      @complete_value_year_totals_remain = @complete_value_year_totals_remain[1..]
      @complete_value_totals_per_staff = @complete_value_totals_per_staff[1..]
      @complete_value_year_totals_per_staff = @complete_value_year_totals_per_staff[1..]
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
