# frozen_string_literal: true

class Report::SubsidiariesOperatingComparisonsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @year_options = policy_scope(Bi::YearReportHistory).year_options
    @year_names = params[:year_names]
    @month_names = policy_scope(Bi::YearReportHistory).month_names
    @month_name = params[:month_name]&.strip || @month_names.first
    @orgs_options = params[:orgs]

    @year_names = @year_options - [2017, 2016] if @year_names.blank?
    data = policy_scope(Bi::YearReportHistory).where(year: @year_names, month: 1..@month_name.to_i)

    all_company_orgcodes = data.pluck(:orgcode).uniq
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ['000103'] if @orgs_options.blank? # hide 天华节能
    @organization_options = all_company_short_names.zip(all_company_orgcodes)

    data = data
      .select('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode, SUM(realamount) realamount, SUM(contractamount) contractamount')
      .group('ORG_ORDER.org_order, YEAR_REPORT_HISTORY.orgcode')
      .where(orgcode: @orgs_options)
      .joins('INNER JOIN ORG_ORDER on ORG_ORDER.org_code = YEAR_REPORT_HISTORY.orgcode')
      .order('ORG_ORDER.org_order DESC, YEAR_REPORT_HISTORY.orgcode')

    show_org_codes = data.collect(&:orgcode).uniq
    @years_real_amounts = {}
    @year_names.each do |year|
      real_amount_array = data.where(year: year).collect { |d| (d.realamount.to_f / 100.0).round(0) }
      @years_real_amounts[year] = real_amount_array
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
