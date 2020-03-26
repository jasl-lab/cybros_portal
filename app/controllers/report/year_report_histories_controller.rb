# frozen_string_literal: true

class Report::YearReportHistoriesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @year_month_names = policy_scope(Bi::YearReportHistory).year_month_names
    @year_month = params[:month_name]&.strip || @year_month_names.first
    @orgs_options = params[:orgs]


    data = policy_scope(Bi::YearReportHistory).where(year_month: @year_month)

    all_company_orgcodes = data.collect(&:orgcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @orgs_options = all_company_orgcodes - ['000103'] if @orgs_options.blank? # hide 天华节能
    @organization_options = all_company_short_names.zip(all_company_orgcodes)
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
