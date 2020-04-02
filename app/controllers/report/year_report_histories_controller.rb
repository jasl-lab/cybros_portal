# frozen_string_literal: true

class Report::YearReportHistoriesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @year_options = policy_scope(Bi::YearReportHistory).year_options
    @year_names = params[:year_names]
    @month_names = policy_scope(Bi::YearReportHistory).month_names
    @month_name = params[:month_name]&.strip || Time.now.month
    @orgs_options = params[:orgs]

    @year_names = @year_options if @year_names.blank?
    data = policy_scope(Bi::YearReportHistory).where(year: @year_names, month: 1..@month_name.to_i).order(:year)

    all_company_orgcodes = data.collect(&:orgcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ['000103', '000149', '000150', '000130', '00012801'] if @orgs_options.blank? # hide 天华节能
    @organization_options = all_company_short_names.zip(all_company_orgcodes)

    @data = data.where(orgcode: @orgs_options)
      .select('year, SUM(IFNULL(realamount,0)) realamount, SUM(IFNULL(contractamount,0)) contractamount, SUM(IFNULL(deptvalue,0)) deptvalue')
      .group(:year)

    @years = @data.collect(&:year)
    @real_amount = @data.collect { |d| (d.realamount / 100.0).round(0) }
    @contract_amount = @data.collect { |d| (d.contractamount / 100.0).round(0) }
    @dept_amount = @data.collect { |d| (d.deptvalue.to_f / 100.0).round(0) }

    rest_years = @year_names.filter { |y| y != Time.now.year.to_s }
    @head_count_data = policy_scope(Bi::YearReportHistory).where(year: rest_years, month: @month_name.to_i)
      .or(policy_scope(Bi::YearReportHistory).where(year: Time.now.year, month: (@month_name.to_i < Time.now.month ? @month_name.to_i : Time.now.month)))
      .where(orgcode: @orgs_options)
      .select('year, SUM(IFNULL(avg_staff_no,0)) avg_staff_no, SUM(IFNULL(avg_work_no,0)) avg_work_no')
      .group(:year)

    @work_head_count = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      head_count.avg_work_no.round(0) rescue 0
    end

    @avg_staff_dept_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      (d.deptvalue / head_count.avg_staff_no.to_f).round(0) rescue 0
    end

    @avg_work_dept_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      (d.deptvalue / head_count.avg_work_no.to_f).round(0) rescue 0
    end

    @avg_staff_real_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      (d.realamount / head_count.avg_staff_no.to_f).round(0) rescue 0
    end

    @avg_work_real_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
      (d.realamount / head_count.avg_work_no.to_f).round(0) rescue 0
    end

    @avg_staff_contract_amount = @data.collect do |d|
      head_count = @head_count_data.find { |h| h.year.to_i == d.year.to_i }
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
