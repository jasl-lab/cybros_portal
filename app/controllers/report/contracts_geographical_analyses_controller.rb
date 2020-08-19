# frozen_string_literal: true

class Report::ContractsGeographicalAnalysesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_year_names = policy_scope(Bi::ContractPrice, :overview_resolve).all_year_names
    @year_names = params[:year_names]
    @orgs_options = params[:orgs]

    @year_names = @all_year_names - [2017, 2016] if @year_names.blank?

    all_company_orgcodes = policy_scope(Bi::ContractPrice, :overview_resolve).select(:businessltdcode).distinct.where('YEAR(filingtime) in (?)', @year_names).pluck(:businessltdcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @orgs_options = all_company_orgcodes if @orgs_options.blank?

    @years_sum_一线, @years_sum_二线, @years_sum_非一二线 = \
      一线二线非一二线_contract_price(@year_names, @orgs_options)

    @西南区域_sum_years, @华东区域_sum_years, @华南区域_sum_years, \
    @华中区域_sum_years, @东北区域_sum_years, @华北区域_sum_years, @西北区域_sum_years = 区域_contract_price(@year_names, @orgs_options)

    @years_sum_省市 = 省市_contract_price(@year_names, @orgs_options)
  end

  private

    def 一线二线非一二线_contract_price(year_names, orgs_options)
      sum_scope = policy_scope(Bi::ContractPrice, :overview_resolve)
        .select('YEAR(filingtime) year_name, citylevel, SUM(subtotal) subtotal')
        .group('YEAR(filingtime), citylevel')
        .where('YEAR(filingtime) in (?)', year_names)
        .where(businessltdcode: orgs_options)
        .order('YEAR(filingtime) DESC') # should same order of @year_names

      years_sum_一线 = []
      years_sum_二线 = []
      years_sum_非一二线 = []
      year_names.each do |year|
        years_sum_一线 << sum_scope.find { |c| c.year_name == year.to_i && c.citylevel == '一线' }&.subtotal
        years_sum_二线 << sum_scope.find { |c| c.year_name == year.to_i && c.citylevel == '二线' }&.subtotal
        years_sum_非一二线 << sum_scope.find { |c| c.year_name == year.to_i && (c.citylevel == '非一二线' || c.citylevel == '三四线城市') }&.subtotal
      end
      years_sum_一线 = years_sum_一线.map { |d| (d/10000_00.0).round(2) }
      years_sum_二线 = years_sum_二线.map { |d| (d/10000_00.0).round(2) }
      years_sum_非一二线 = years_sum_非一二线.map { |d| (d/10000_00.0).round(2) }
      return [years_sum_一线, years_sum_二线, years_sum_非一二线]
    end

    def 区域_contract_price(year_names, orgs_options)
      sum_scope = policy_scope(Bi::ContractPrice, :overview_resolve)
        .select('YEAR(filingtime) year_name, area, SUM(subtotal) subtotal')
        .group('YEAR(filingtime), area')
        .where('YEAR(filingtime) in (?)', year_names)
        .where(businessltdcode: orgs_options)
        .order('YEAR(filingtime) DESC') # should same order of @year_names

      西南区域_sum_years = sum_scope.filter_map  { |c| (c.subtotal/10000_00.0).round(2) if c.area == '西南区域' }
      华东区域_sum_years = sum_scope.filter_map  { |c| (c.subtotal/10000_00.0).round(2) if c.area == '华东区域' }
      华南区域_sum_years = sum_scope.filter_map  { |c| (c.subtotal/10000_00.0).round(2) if c.area == '华南区域' }
      华中区域_sum_years = sum_scope.filter_map  { |c| (c.subtotal/10000_00.0).round(2) if c.area == '华中区域' }
      东北区域_sum_years = sum_scope.filter_map  { |c| (c.subtotal/10000_00.0).round(2) if c.area == '东北区域' }
      华北区域_sum_years = sum_scope.filter_map  { |c| (c.subtotal/10000_00.0).round(2) if c.area == '华北区域' }
      西北区域_sum_years = sum_scope.filter_map  { |c| (c.subtotal/10000_00.0).round(2) if c.area == '西北区域' }

      return [西南区域_sum_years, 华东区域_sum_years, 华南区域_sum_years, \
        华中区域_sum_years, 东北区域_sum_years, 华北区域_sum_years, 西北区域_sum_years]
    end

    def 省市_contract_price(year_names, orgs_options)
      sum_scope = policy_scope(Bi::ContractPrice, :overview_resolve)
        .select('provincename, SUM(subtotal) subtotal')
        .group('provincename')
        .where('YEAR(filingtime) in (?)', year_names)
        .where(businessltdcode: orgs_options)

      sum_台湾 = sum_scope.find { |c| c.provincename == '台湾省' }&.subtotal
      sum_河北 = sum_scope.find { |c| c.provincename == '河北省' }&.subtotal
      sum_山西 = sum_scope.find { |c| c.provincename == '山西省' }&.subtotal
      sum_内蒙古 = sum_scope.find { |c| c.provincename == '内蒙古自治区' }&.subtotal
      sum_辽宁 = sum_scope.find { |c| c.provincename == '辽宁省' }&.subtotal
      sum_吉林 = sum_scope.find { |c| c.provincename == '吉林省' }&.subtotal
      sum_黑龙江 = sum_scope.find { |c| c.provincename == '黑龙江省' }&.subtotal

      sum_江苏 = sum_scope.find { |c| c.provincename == '江苏省' }&.subtotal
      sum_浙江 = sum_scope.find { |c| c.provincename == '浙江省' }&.subtotal
      sum_安徽 = sum_scope.find { |c| c.provincename == '安徽省' }&.subtotal
      sum_福建 = sum_scope.find { |c| c.provincename == '福建省' }&.subtotal
      sum_江西 = sum_scope.find { |c| c.provincename == '江西省' }&.subtotal
      sum_山东 = sum_scope.find { |c| c.provincename == '山东省' }&.subtotal
      sum_河南 = sum_scope.find { |c| c.provincename == '河南省' }&.subtotal

      sum_湖北 = sum_scope.find { |c| c.provincename == '湖北省' }&.subtotal
      sum_湖南 = sum_scope.find { |c| c.provincename == '湖南省' }&.subtotal
      sum_广东 = sum_scope.find { |c| c.provincename == '广东省' }&.subtotal
      sum_广西 = sum_scope.find { |c| c.provincename == '广西壮族自治区' }&.subtotal
      sum_海南 = sum_scope.find { |c| c.provincename == '海南省' }&.subtotal
      sum_四川 = sum_scope.find { |c| c.provincename == '四川省' }&.subtotal
      sum_贵州 = sum_scope.find { |c| c.provincename == '贵州省' }&.subtotal

      sum_云南 = sum_scope.find { |c| c.provincename == '云南省' }&.subtotal
      sum_西藏 = sum_scope.find { |c| c.provincename == '西藏自治区' }&.subtotal
      sum_陕西 = sum_scope.find { |c| c.provincename == '陕西省' }&.subtotal
      sum_甘肃 = sum_scope.find { |c| c.provincename == '甘肃省' }&.subtotal
      sum_青海 = sum_scope.find { |c| c.provincename == '青海省' }&.subtotal
      sum_宁夏 = sum_scope.find { |c| c.provincename == '宁夏回族自治区' }&.subtotal
      sum_新疆 = sum_scope.find { |c| c.provincename == '新疆维吾尔自治区' }&.subtotal

      sum_北京 = sum_scope.find { |c| c.provincename == '北京市' }&.subtotal
      sum_天津 = sum_scope.find { |c| c.provincename == '天津市' }&.subtotal
      sum_上海 = sum_scope.find { |c| c.provincename == '上海市' }&.subtotal
      sum_重庆 = sum_scope.find { |c| c.provincename == '重庆市' }&.subtotal
      sum_香港 = sum_scope.find { |c| c.provincename == '香港特别行政区' }&.subtotal
      sum_澳门 = sum_scope.find { |c| c.provincename == '澳门特别行政区' }&.subtotal

      # There is no place to drawing c.provincename == '其他' and '海外'

      sum_省市 = [ sum_台湾, sum_河北, sum_山西, sum_内蒙古, sum_辽宁, sum_吉林, sum_黑龙江,
                  sum_江苏, sum_浙江, sum_安徽, sum_福建, sum_江西, sum_山东, sum_河南,
                  sum_湖北, sum_湖南, sum_广东, sum_广西, sum_海南, sum_四川, sum_贵州,
                  sum_云南, sum_西藏, sum_陕西, sum_甘肃, sum_青海, sum_宁夏, sum_新疆,
                  sum_北京, sum_天津, sum_上海, sum_重庆, sum_香港, sum_澳门 ]
      sum_省市.map { |d| d.nil? ? nil : (d / 10000_00.0).round(1) }
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
