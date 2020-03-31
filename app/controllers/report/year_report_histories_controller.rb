# frozen_string_literal: true

class Report::YearReportHistoriesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @year_options = policy_scope(Bi::YearReportHistory).year_options
    @year_names = params[:year_names]
    @month_names = policy_scope(Bi::YearReportHistory).month_names
    @month_name = params[:month_name]&.strip || @month_names.first
    @orgs_options = params[:orgs]


    @year_names = @year_options if @year_names.blank?
    data = policy_scope(Bi::YearReportHistory).where(year: @year_names, month: 1..@month_name.to_i).order(:year)

    all_company_orgcodes = data.collect(&:orgcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ['000103'] if @orgs_options.blank? # hide 天华节能
    @organization_options = all_company_short_names.zip(all_company_orgcodes)

    @data = data.where(orgcode: @orgs_options)
      .select('year, SUM(realamount) realamount, SUM(contractamount) contractamount')
      .group(:year)

    @years = @data.collect(&:year)
    @real_amount = @data.collect { |d| (d.realamount / 100.0).round(0) }
    @contract_amount = @data.collect { |d| (d.contractamount / 100.0).round(0) }

    @head_count_data = policy_scope(Bi::YearReportHistory)
      .where(orgcode: @orgs_options)
      .where(year: @year_names, month: @month_name.to_i)
      .select('year, SUM(avg_staff_no) avg_staff_no, SUM(avg_work_no) avg_work_no')
      .group(:year)

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
