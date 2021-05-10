# frozen_string_literal: true

class Report::YearReportHistoriesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @year_options = policy_scope(Bi::YearReportHistory).year_options
    @year_names = params[:year_names]
    @month_names = policy_scope(Bi::YearReportHistory).month_names
    @month_name = params[:month_name]&.strip || Time.now.month == 1 ? 12 : Time.now.month - 1
    @orgs_options = params[:orgs]
    @view_orgcode_sum = params[:view_orgcode_sum] == 'true'

    @year_names = @year_options if @year_names.blank?
    data = policy_scope(Bi::YearReportHistory).where(year: @year_names, month: 1..@month_name.to_i).order(:year)
    last_month_data = if @month_name.to_i == 1
      policy_scope(Bi::YearReportHistory).where(year: @year_names, month: 1..@month_name.to_i).order(:year)
    else
      policy_scope(Bi::YearReportHistory).where(year: @year_names, month: 1..(@month_name.to_i - 1)).order(:year)
    end

    all_company_orgcodes = data
      .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = YEAR_REPORT_HISTORY.orgcode')
      .where('ORG_ORDER.org_order is not null')
      .where("ORG_ORDER.org_type = '创意板块'")
      .order('ORG_ORDER.org_order ASC')
      .collect { |y| @view_orgcode_sum ? y.orgcode_sum : y.orgcode } - ['000103', '000149', '000150', '000130', '00012801', '000119']
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes if @orgs_options.blank?
    @organization_options = all_company_short_names.zip(all_company_orgcodes)

    @data = if @view_orgcode_sum
      data.where(orgcode_sum: @orgs_options)
    else
      data.where(orgcode: @orgs_options)
    end.select('year, SUM(IFNULL(realamount,0)) realamount, SUM(IFNULL(contractamount,0)) contractamount, SUM(IFNULL(deptvalue,0)) deptvalue')
       .group(:year)
    last_month_data = if @view_orgcode_sum
      last_month_data.where(orgcode_sum: @orgs_options)
    else
      last_month_data.where(orgcode: @orgs_options)
    end.select('year, SUM(IFNULL(realamount,0)) realamount, SUM(IFNULL(contractamount,0)) contractamount, SUM(IFNULL(deptvalue,0)) deptvalue')
      .group(:year)

    @years = @data.collect(&:year)
    @real_amount = @data.collect { |d| (d.realamount / 100.0).round(0) }
    @last_month_real_amount = last_month_data.collect { |d| (d.realamount / 100.0).round(0) }
    @this_month_real_amount = @real_amount.zip(@last_month_real_amount).map { |d| d[0] - d[1] }

    @contract_amount = @data.collect { |d| (d.contractamount / 100.0).round(0) }
    @last_month_contract_amount = last_month_data.collect { |d| (d.contractamount / 100.0).round(0) }
    @this_month_contract_amount = @contract_amount.zip(@last_month_contract_amount).map { |d| d[0] - d[1] }

    @dept_amount = @data.collect { |d| (d.deptvalue.to_f / 100.0).round(0) }
    @last_month_dept_amount = last_month_data.collect { |d| (d.deptvalue.to_f / 100.0).round(0) }
    @this_month_dept_amount = @dept_amount.zip(@last_month_dept_amount).map { |d| d[0] - d[1] }

    most_recent_year = @year_names.first
    most_recent_month = @month_name.to_i
    end_of_month = Time.new(most_recent_year, most_recent_month, 1).end_of_month
    @last_available_sign_dept_date = policy_scope(Bi::ContractSignDept).last_available_date(end_of_month)

    rest_years = @year_names.filter { |y| y != Time.now.year.to_s }
    head_count_data = policy_scope(Bi::YearReportHistory).where(year: rest_years, month: @month_name.to_i)
      .or(policy_scope(Bi::YearReportHistory).where(year: Time.now.year, month: (@month_name.to_i < Time.now.month ? @month_name.to_i : Time.now.month)))

    @head_count_data = if @view_orgcode_sum
      head_count_data.where(orgcode_sum: @orgs_options)
    else
      head_count_data.where(orgcode: @orgs_options)
    end.select('year, SUM(IFNULL(avg_staff_no,0)) avg_staff_no, SUM(IFNULL(avg_work_no,0)) avg_work_no')
      .group(:year)

    @avg_staff_no_head_count = Bi::HrMonthReport.按月子公司全员人数(@month_name.to_i, @orgs_options, @view_orgcode_sum)

    @work_head_count = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      head_count.avg_work_no.round(0) rescue 0
    end

    @avg_staff_dept_amount = @data.collect do |d|
      head_count = @avg_staff_no_head_count.find { |h| h.year.to_i == d.year.to_i }
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i } if head_count.blank? || head_count.avg_staff_no.blank?
      (d.deptvalue / head_count.avg_staff_no.to_f).round(0) rescue 0
    end

    @avg_work_dept_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      (d.deptvalue / head_count.avg_work_no.to_f).round(0) rescue 0
    end

    @avg_staff_real_amount = @data.collect do |d|
      head_count = @avg_staff_no_head_count.find { |h| h.year.to_i == d.year.to_i }
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i } if head_count.blank? || head_count.avg_staff_no.blank?
      (d.realamount / head_count.avg_staff_no.to_f).round(0) rescue 0
    end

    @avg_work_real_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      (d.realamount / head_count.avg_work_no.to_f).round(0) rescue 0
    end

    @avg_staff_contract_amount = @data.collect do |d|
      head_count = @avg_staff_no_head_count.find { |h| h.year.to_i == d.year.to_i }
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i } if head_count.blank? || head_count.avg_staff_no.blank?
      (d.contractamount / head_count.avg_staff_no.to_f).round(0) rescue 0
    end

    @avg_work_contract_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      (d.contractamount / head_count.avg_work_no.to_f).round(0) rescue 0
    end
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.year_report_history'),
        link: report_year_report_history_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
