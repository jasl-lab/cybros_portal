# frozen_string_literal: true

class Report::ContractsGeographicalAnalysesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_year_names = Bi::ContractPrice.all_year_names
    @year_names = params[:year_names]
    @orgs_options = params[:orgs]

    data = Bi::ContractPrice
      .group(:businessltdcode)
      .select('businessltdcode, SUM(realamounttotal) realamounttotal')
      .order('SUM(realamounttotal) DESC')

    @year_names = @all_year_names if @year_names.blank?
    data = data.where('YEAR(filingtime) in (?)', @year_names)

    all_company_orgcodes = data.collect(&:businessltdcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @orgs_options = all_company_orgcodes if @orgs_options.blank?
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.contracts_geographical_analysis'),
        link: report_contracts_geographical_analysis_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
