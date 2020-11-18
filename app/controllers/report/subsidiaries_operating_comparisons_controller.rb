# frozen_string_literal: true

class Report::SubsidiariesOperatingComparisonsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @year_options = policy_scope(Bi::YearReportHistory).year_options
    @year_names = params[:year_names]
    @month_names = policy_scope(Bi::YearReportHistory).month_names
    @month_name = params[:month_name]&.strip || Time.now.last_month.month
    @orgs_options = params[:orgs]
    @view_orgcode_sum = params[:view_orgcode_sum] == 'true'

    @year_names = @year_options - [2017, 2016] if @year_names.blank?
    data = policy_scope(Bi::YearReportHistory).where(year: @year_names, month: 1..@month_name.to_i)

    all_company_orgcodes = data
      .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = YEAR_REPORT_HISTORY.orgcode')
      .where('ORG_ORDER.org_order is not null')
      .order('ORG_ORDER.org_order ASC')
      .collect { |y| @view_orgcode_sum ? y.orgcode_sum : y.orgcode }.uniq
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes if @orgs_options.blank? # hide 天华节能
    @organization_options = all_company_short_names.zip(all_company_orgcodes)

    data = if @view_orgcode_sum
      data.select('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode_sum orgcode, SUM(IFNULL(realamount,0)) realamount, SUM(IFNULL(contractamount,0)) contractamount, SUM(IFNULL(deptvalue,0)) deptvalue')
        .group('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode_sum')
        .where(orgcode_sum: @orgs_options)
        .joins('INNER JOIN ORG_ORDER on ORG_ORDER.org_code = YEAR_REPORT_HISTORY.orgcode_sum')
        .order('ORG_ORDER.org_order ASC, YEAR_REPORT_HISTORY.orgcode_sum')
    else
      data.select('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode, SUM(IFNULL(realamount,0)) realamount, SUM(IFNULL(contractamount,0)) contractamount, SUM(IFNULL(deptvalue,0)) deptvalue')
        .group('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode')
        .where(orgcode: @orgs_options)
        .joins('INNER JOIN ORG_ORDER on ORG_ORDER.org_code = YEAR_REPORT_HISTORY.orgcode')
        .order('ORG_ORDER.org_order ASC, YEAR_REPORT_HISTORY.orgcode')
    end
    show_org_codes = data.collect(&:orgcode)

    most_recent_year = @year_names.first
    most_recent_month = (@month_name.to_i < Time.now.last_month.month ? @month_name.to_i : Time.now.last_month.month)
    end_of_month = Time.new(most_recent_year, most_recent_month, 1).end_of_month
    @last_available_sign_dept_date = policy_scope(Bi::ContractSignDept).last_available_date(end_of_month)

    most_recent_data = if @view_orgcode_sum
      policy_scope(Bi::YearReportHistory).where(year: most_recent_year, month: most_recent_month)
        .group('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode_sum')
        .where(orgcode_sum: @orgs_options)
        .select('orgcode_sum, SUM(IFNULL(avg_staff_no_sum,0)) avg_staff_no, SUM(IFNULL(avg_work_no_sum,0)) avg_work_no')
        .joins('INNER JOIN ORG_ORDER on ORG_ORDER.org_code = YEAR_REPORT_HISTORY.orgcode_sum')
        .order('ORG_ORDER.org_order ASC, YEAR_REPORT_HISTORY.orgcode_sum')
    else
      policy_scope(Bi::YearReportHistory).where(year: most_recent_year, month: most_recent_month)
        .group('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode')
        .where(orgcode: @orgs_options)
        .select('orgcode, SUM(IFNULL(avg_staff_no,0)) avg_staff_no, SUM(IFNULL(avg_work_no,0)) avg_work_no')
        .joins('INNER JOIN ORG_ORDER on ORG_ORDER.org_code = YEAR_REPORT_HISTORY.orgcode')
        .order('ORG_ORDER.org_order ASC, YEAR_REPORT_HISTORY.orgcode')
    end

    @most_recent_avg_work_no = most_recent_data.collect { |d| d.avg_work_no.round(0) }
    @most_recent_avg_staff_no = most_recent_data.collect { |d| d.avg_staff_no.round(0) }
    rest_years = @year_names.filter { |y| y != Time.now.year.to_s }

    head_count_data = policy_scope(Bi::YearReportHistory).where(year: rest_years, month: @month_name.to_i)
      .or(policy_scope(Bi::YearReportHistory).where(year: Time.now.year, month: most_recent_month))

    @head_count_data = if @view_orgcode_sum
      head_count_data.where(orgcode_sum: @orgs_options)
        .select('orgcode_sum orgcode, year, SUM(avg_staff_no_sum) avg_staff_no, SUM(avg_work_no_sum) avg_work_no')
        .group('orgcode_sum, year')
        .order('orgcode_sum, year')
    else
      head_count_data.where(orgcode: @orgs_options)
        .select('orgcode, year, SUM(avg_staff_no) avg_staff_no, SUM(avg_work_no) avg_work_no')
        .group('orgcode, year')
        .order('orgcode, year')
    end

    @years_dept_values = {}
    @missing_org_code_in_year = {}
    @avg_staff_dept_values = {}
    @avg_work_dept_values = {}

    @years_contract_amounts = {}
    @avg_staff_contract_amounts = {}
    @avg_work_contract_amounts = {}

    @years_real_amounts = {}
    @avg_staff_real_amounts = {}
    @avg_work_real_amounts = {}

    @year_names.each do |year|
      year_data = data.where(year: year)
      year_org_codes = year_data.collect(&:orgcode)
      @missing_org_code_in_year[year] = show_org_codes - year_org_codes
      @years_dept_values[year] = year_data.collect { |d| (d.deptvalue.to_f / 100.0).round(0) }

      @avg_staff_dept_values[year] = year_data.collect do |d|
        head_count = @head_count_data.find { |h| h.year.to_i == year.to_i && d.orgcode == h.orgcode }
        (d.deptvalue / head_count.avg_staff_no.to_f).round(0) rescue 0
      end
      @avg_work_dept_values[year] = year_data.collect do |d|
        head_count = @head_count_data.find { |h| h.year.to_i == year.to_i && d.orgcode == h.orgcode }
        (d.deptvalue / head_count.avg_work_no.to_f).round(0) rescue 0
      end

      @years_contract_amounts[year] = year_data.collect { |d| (d.contractamount.to_f / 100.0).round(0) }
      @avg_staff_contract_amounts[year] = year_data.collect do |d|
        head_count = @head_count_data.find { |h| h.year.to_i == year.to_i && d.orgcode == h.orgcode }
        (d.contractamount / head_count.avg_staff_no.to_f).round(0) rescue 0
      end
      @avg_work_contract_amounts[year] = year_data.collect do |d|
        head_count = @head_count_data.find { |h| h.year.to_i == year.to_i && d.orgcode == h.orgcode }
        (d.contractamount / head_count.avg_work_no.to_f).round(0) rescue 0
      end

      @years_real_amounts[year] = year_data.collect { |d| (d.realamount.to_f / 100.0).round(0) }
      @avg_staff_real_amounts[year] = year_data.collect do |d|
        head_count = @head_count_data.find { |h| h.year.to_i == year.to_i && d.orgcode == h.orgcode }
        (d.realamount / head_count.avg_staff_no.to_f).round(0) rescue 0
      end
      @avg_work_real_amounts[year] = year_data.collect do |d|
        head_count = @head_count_data.find { |h| h.year.to_i == year.to_i && d.orgcode == h.orgcode }
        (d.realamount / head_count.avg_work_no.to_f).round(0) rescue 0
      end
    end
    @no_missing_data = @missing_org_code_in_year.all?(&:blank?)
    @missing_org_code_in_year = unless @no_missing_data
      @missing_org_code_in_year.transform_values { |v| v.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) } }
    end
    @show_org_names = show_org_codes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.subsidiaries_operating_comparison'),
        link: report_subsidiaries_operating_comparison_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
