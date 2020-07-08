# frozen_string_literal: true

class Report::ContractsGeographicalAnalysesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_year_names = policy_scope(Bi::ContractPrice).all_year_names
    @year_names = params[:year_names]
    @orgs_options = params[:orgs]

    @year_names = @all_year_names if @year_names.blank?

    all_company_orgcodes = policy_scope(Bi::ContractPrice).select(:businessltdcode).distinct.where('YEAR(filingtime) in (?)', @year_names).pluck(:businessltdcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @orgs_options = all_company_orgcodes if @orgs_options.blank?

    @years_sum_一线, @years_sum_二线, @years_sum_三四线城市 = \
      一线二线三四线_contract_price(@year_names, @orgs_options)

    @years_sum_西南区域, @years_sum_华东区域, @years_sum_华南区域, @years_sum_华中区域, @years_sum_东北区域, @years_sum_华北区域, @years_sum_西北区域  = \
      区域_contract_price(@year_names, @orgs_options)

    @years_sum_省市 = 省市_contract_price(@year_names, @orgs_options)
  end

  private

    def 一线二线三四线_contract_price(year_names, orgs_options)
      sum_scope = policy_scope(Bi::ContractPrice)
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
      sum_scope = policy_scope(Bi::ContractPrice)
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

    def 省市_contract_price(year_names, orgs_options)
      sum_scope = policy_scope(Bi::ContractPrice)
        .select('provincename, SUM(realamounttotal) realamounttotal')
        .group('provincename')
        .where('YEAR(filingtime) in (?)', year_names)
        .where(businessltdcode: orgs_options)

      sum_台湾 = sum_scope.find { |c| c.provincename == '台湾省' }&.realamounttotal
      sum_河北 = sum_scope.find { |c| c.provincename == '河北省' }&.realamounttotal
      sum_山西 = sum_scope.find { |c| c.provincename == '山西省' }&.realamounttotal
      sum_内蒙古 = sum_scope.find { |c| c.provincename == '内蒙古自治区' }&.realamounttotal
      sum_辽宁 = sum_scope.find { |c| c.provincename == '辽宁省' }&.realamounttotal
      sum_吉林 = sum_scope.find { |c| c.provincename == '吉林省' }&.realamounttotal
      sum_黑龙江 = sum_scope.find { |c| c.provincename == '黑龙江省' }&.realamounttotal

      sum_江苏 = sum_scope.find { |c| c.provincename == '江苏省' }&.realamounttotal
      sum_浙江 = sum_scope.find { |c| c.provincename == '浙江省' }&.realamounttotal
      sum_安徽 = sum_scope.find { |c| c.provincename == '安徽省' }&.realamounttotal
      sum_福建 = sum_scope.find { |c| c.provincename == '福建省' }&.realamounttotal
      sum_江西 = sum_scope.find { |c| c.provincename == '江西省' }&.realamounttotal
      sum_山东 = sum_scope.find { |c| c.provincename == '山东省' }&.realamounttotal
      sum_河南 = sum_scope.find { |c| c.provincename == '河南省' }&.realamounttotal

      sum_湖北 = sum_scope.find { |c| c.provincename == '湖北省' }&.realamounttotal
      sum_湖南 = sum_scope.find { |c| c.provincename == '湖南省' }&.realamounttotal
      sum_广东 = sum_scope.find { |c| c.provincename == '广东省' }&.realamounttotal
      sum_广西 = sum_scope.find { |c| c.provincename == '广西壮族自治区' }&.realamounttotal
      sum_海南 = sum_scope.find { |c| c.provincename == '海南省' }&.realamounttotal
      sum_四川 = sum_scope.find { |c| c.provincename == '四川省' }&.realamounttotal
      sum_贵州 = sum_scope.find { |c| c.provincename == '贵州省' }&.realamounttotal

      sum_云南 = sum_scope.find { |c| c.provincename == '云南省' }&.realamounttotal
      sum_西藏 = sum_scope.find { |c| c.provincename == '西藏自治区' }&.realamounttotal
      sum_陕西 = sum_scope.find { |c| c.provincename == '陕西省' }&.realamounttotal
      sum_甘肃 = sum_scope.find { |c| c.provincename == '甘肃省' }&.realamounttotal
      sum_青海 = sum_scope.find { |c| c.provincename == '青海省' }&.realamounttotal
      sum_宁夏 = sum_scope.find { |c| c.provincename == '宁夏回族自治区' }&.realamounttotal
      sum_新疆 = sum_scope.find { |c| c.provincename == '新疆维吾尔自治区' }&.realamounttotal

      sum_北京 = sum_scope.find { |c| c.provincename == '北京市' }&.realamounttotal
      sum_天津 = sum_scope.find { |c| c.provincename == '天津市' }&.realamounttotal
      sum_上海 = sum_scope.find { |c| c.provincename == '上海市' }&.realamounttotal
      sum_重庆 = sum_scope.find { |c| c.provincename == '重庆市' }&.realamounttotal
      sum_香港 = sum_scope.find { |c| c.provincename == '香港特别行政区' }&.realamounttotal
      sum_澳门 = sum_scope.find { |c| c.provincename == '澳门特别行政区' }&.realamounttotal

      # There is no place to drawing c.provincename == '其他' and '海外'

      sum_省市 = [ sum_台湾, sum_河北, sum_山西, sum_内蒙古, sum_辽宁, sum_吉林, sum_黑龙江,
                  sum_江苏, sum_浙江, sum_安徽, sum_福建, sum_江西, sum_山东, sum_河南,
                  sum_湖北, sum_湖南, sum_广东, sum_广西, sum_海南, sum_四川, sum_贵州,
                  sum_云南, sum_西藏, sum_陕西, sum_甘肃, sum_青海, sum_宁夏, sum_新疆,
                  sum_北京, sum_天津, sum_上海, sum_重庆, sum_香港, sum_澳门 ]
      sum_省市.map { |d| d.nil? ? nil : (d/10000_00.0).round(2) }
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
