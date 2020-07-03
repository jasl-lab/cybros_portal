# frozen_string_literal: true

class Report::ContractsGeographicalAnalysesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_year_names = Bi::ContractPrice.all_year_names
    @year_names = params[:year_names]
    @orgs_options = params[:orgs]

    @year_names = @all_year_names if @year_names.blank?

    all_company_orgcodes = Bi::ContractPrice.select(:businessltdcode).distinct.where('YEAR(filingtime) in (?)', @year_names).pluck(:businessltdcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @orgs_options = all_company_orgcodes if @orgs_options.blank?

    @years_sum_一线, @years_sum_二线, @years_sum_三四线城市 = \
      一线二线三四线_contract_price(@year_names, @orgs_options)

    @years_sum_西南区域, @years_sum_华东区域, @years_sum_华南区域, @years_sum_华中区域, @years_sum_东北区域, @years_sum_华北区域, @years_sum_西北区域  = \
      区域_contract_price(@year_names, @orgs_options)
  end

  private

    def 一线二线三四线_contract_price(year_names, orgs_options)
      sum_scope = Bi::ContractPrice
        .select('YEAR(filingtime) year_name, citylevel, SUM(realamounttotal) realamounttotal')
        .group('YEAR(filingtime), citylevel')
        .where('YEAR(filingtime) in (?)', year_names)
        .where(businessltdcode: orgs_options)
      years_sum_一线 = []
      years_sum_二线 = []
      years_sum_三四线城市 = []
      year_names.each do |year|
        years_sum_一线 << sum_scope.find { |c| c.year_name == year.to_i && c.citylevel == '一线' }&.realamounttotal
        years_sum_二线 << sum_scope.find { |c| c.year_name == year.to_i && c.citylevel == '二线' }&.realamounttotal
        years_sum_三四线城市 << sum_scope.find { |c| c.year_name == year.to_i && c.citylevel == '三四线城市' }&.realamounttotal
      end
      years_sum_一线 = years_sum_一线.map { |d| (d/10000_00.0).round(2) }
      years_sum_二线 = years_sum_二线.map { |d| (d/10000_00.0).round(2) }
      years_sum_三四线城市 = years_sum_三四线城市.map { |d| (d/10000_00.0).round(2) }
      return [years_sum_一线, years_sum_二线, years_sum_三四线城市]
    end

    def 区域_contract_price(year_names, orgs_options)
      sum_scope = Bi::ContractPrice
        .select('YEAR(filingtime) year_name, area, SUM(realamounttotal) realamounttotal')
        .group('YEAR(filingtime), area')
        .where('YEAR(filingtime) in (?)', year_names)
        .where(businessltdcode: orgs_options)

      years_sum_西南区域 = []
      years_sum_华东区域 = []
      years_sum_华南区域 = []
      years_sum_华中区域 = []
      years_sum_东北区域 = []
      years_sum_华北区域 = []
      years_sum_西北区域 = []

      year_names.each do |year|
        years_sum_西南区域 << sum_scope.find { |c| c.year_name == year.to_i && c.area == '西南区域' }&.realamounttotal
        years_sum_华东区域 << sum_scope.find { |c| c.year_name == year.to_i && c.area == '华东区域' }&.realamounttotal
        years_sum_华南区域 << sum_scope.find { |c| c.year_name == year.to_i && c.area == '华南区域' }&.realamounttotal
        years_sum_华中区域 << sum_scope.find { |c| c.year_name == year.to_i && c.area == '华中区域' }&.realamounttotal
        years_sum_东北区域 << sum_scope.find { |c| c.year_name == year.to_i && c.area == '东北区域' }&.realamounttotal
        years_sum_华北区域 << sum_scope.find { |c| c.year_name == year.to_i && c.area == '华北区域' }&.realamounttotal
        years_sum_西北区域 << sum_scope.find { |c| c.year_name == year.to_i && c.area == '西北区域' }&.realamounttotal
      end

      years_sum_西南区域 = years_sum_西南区域.map { |d| (d/10000_00.0).round(2) }
      years_sum_华东区域 = years_sum_华东区域.map { |d| (d/10000_00.0).round(2) }
      years_sum_华南区域 = years_sum_华南区域.map { |d| (d/10000_00.0).round(2) }
      years_sum_华中区域 = years_sum_华中区域.map { |d| (d/10000_00.0).round(2) }
      years_sum_东北区域 = years_sum_东北区域.map { |d| (d/10000_00.0).round(2) }
      years_sum_华北区域 = years_sum_华北区域.map { |d| (d/10000_00.0).round(2) }
      years_sum_西北区域 = years_sum_西北区域.map { |d| (d/10000_00.0).round(2) }
      return [years_sum_西南区域, years_sum_华东区域, years_sum_华南区域, years_sum_华中区域, years_sum_东北区域, years_sum_华北区域, years_sum_西北区域]
    end

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
