# frozen_string_literal: true

class Report::ContractProviceAreasController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_year_names = Bi::ContractPrice.all_year_names
    @year_name = params[:year_name]
    @orgs_options = params[:orgs]

    @year_name = @all_year_names.first if @year_name.blank?

    all_company_orgcodes = Bi::ContractPrice.select(:businessltdcode).distinct.where('YEAR(filingtime) in (?)', @year_name).pluck(:businessltdcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @orgs_options = all_company_orgcodes if @orgs_options.blank?

    @year_sum_省市 = 省市_contract_price(@year_name, @orgs_options)
  end

  private

    def 省市_contract_price(year_name, orgs_options)
      sum_scope = Bi::ContractPrice
        .select('provincename, SUM(scale) scale')
        .group('provincename')
        .where('YEAR(filingtime) in (?)', year_name)
        .where(businessltdcode: orgs_options)

      sum_台湾 = sum_scope.find { |c| c.provincename == '台湾省' }&.scale
      sum_河北 = sum_scope.find { |c| c.provincename == '河北省' }&.scale
      sum_山西 = sum_scope.find { |c| c.provincename == '山西省' }&.scale
      sum_内蒙古 = sum_scope.find { |c| c.provincename == '内蒙古自治区' }&.scale
      sum_辽宁 = sum_scope.find { |c| c.provincename == '辽宁省' }&.scale
      sum_吉林 = sum_scope.find { |c| c.provincename == '吉林省' }&.scale
      sum_黑龙江 = sum_scope.find { |c| c.provincename == '黑龙江省' }&.scale

      sum_江苏 = sum_scope.find { |c| c.provincename == '江苏省' }&.scale
      sum_浙江 = sum_scope.find { |c| c.provincename == '浙江省' }&.scale
      sum_安徽 = sum_scope.find { |c| c.provincename == '安徽省' }&.scale
      sum_福建 = sum_scope.find { |c| c.provincename == '福建省' }&.scale
      sum_江西 = sum_scope.find { |c| c.provincename == '江西省' }&.scale
      sum_山东 = sum_scope.find { |c| c.provincename == '山东省' }&.scale
      sum_河南 = sum_scope.find { |c| c.provincename == '河南省' }&.scale

      sum_湖北 = sum_scope.find { |c| c.provincename == '湖北省' }&.scale
      sum_湖南 = sum_scope.find { |c| c.provincename == '湖南省' }&.scale
      sum_广东 = sum_scope.find { |c| c.provincename == '广东省' }&.scale
      sum_广西 = sum_scope.find { |c| c.provincename == '广西壮族自治区' }&.scale
      sum_海南 = sum_scope.find { |c| c.provincename == '海南省' }&.scale
      sum_四川 = sum_scope.find { |c| c.provincename == '四川省' }&.scale
      sum_贵州 = sum_scope.find { |c| c.provincename == '贵州省' }&.scale

      sum_云南 = sum_scope.find { |c| c.provincename == '云南省' }&.scale
      sum_西藏 = sum_scope.find { |c| c.provincename == '西藏自治区' }&.scale
      sum_陕西 = sum_scope.find { |c| c.provincename == '陕西省' }&.scale
      sum_甘肃 = sum_scope.find { |c| c.provincename == '甘肃省' }&.scale
      sum_青海 = sum_scope.find { |c| c.provincename == '青海省' }&.scale
      sum_宁夏 = sum_scope.find { |c| c.provincename == '宁夏回族自治区' }&.scale
      sum_新疆 = sum_scope.find { |c| c.provincename == '新疆维吾尔自治区' }&.scale

      sum_北京 = sum_scope.find { |c| c.provincename == '北京市' }&.scale
      sum_天津 = sum_scope.find { |c| c.provincename == '天津市' }&.scale
      sum_上海 = sum_scope.find { |c| c.provincename == '上海市' }&.scale
      sum_重庆 = sum_scope.find { |c| c.provincename == '重庆市' }&.scale
      sum_香港 = sum_scope.find { |c| c.provincename == '香港特别行政区' }&.scale
      sum_澳门 = sum_scope.find { |c| c.provincename == '澳门特别行政区' }&.scale

      # There is no place to drawing c.provincename == '其他' and '海外'

      [ sum_台湾, sum_河北, sum_山西, sum_内蒙古, sum_辽宁, sum_吉林, sum_黑龙江,
        sum_江苏, sum_浙江, sum_安徽, sum_福建, sum_江西, sum_山东, sum_河南,
        sum_湖北, sum_湖南, sum_广东, sum_广西, sum_海南, sum_四川, sum_贵州,
        sum_云南, sum_西藏, sum_陕西, sum_甘肃, sum_青海, sum_宁夏, sum_新疆,
        sum_北京, sum_天津, sum_上海, sum_重庆, sum_香港, sum_澳门 ]
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.contract_provice_area'),
        link: report_contract_provice_area_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
