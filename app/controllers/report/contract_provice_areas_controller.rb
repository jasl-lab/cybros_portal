# frozen_string_literal: true

class Report::ContractProviceAreasController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(Bi::ProvinceNewArea).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @end_of_month = Date.parse(@month_name).end_of_month
    @beginning_of_year = @end_of_month.beginning_of_year

    @orgs_options = params[:orgs]
    @service_phase = params[:service_phase].presence || '前端'

    all_company_orgcodes = policy_scope(Bi::ContractPrice, :overview_resolve)
      .select(:businessltdcode, :"ORG_ORDER.org_order")
      .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_PRICE.businessltdcode')
      .order('ORG_ORDER.org_order ASC')
      .where(filingtime: @beginning_of_year..@end_of_month).pluck(:businessltdcode).uniq
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    @orgs_options = all_company_orgcodes if @orgs_options.blank?

    sum_cp = filter_contract_price_scope(@beginning_of_year, @end_of_month, @orgs_options, @service_phase)
    @sum_scope = filter_province_new_area_scope(@end_of_month)

    @total_new_area = 0
    @total_scale = 0
    @new_area_rates = @sum_scope.collect do |r|
      cp_r = sum_cp.find { |pr| pr.provincename == r.province }
      @total_new_area += r.new_area.to_i
      @total_scale += cp_r&.scale.to_f
      new_area_rate = if r.new_area.present?
        ((cp_r&.scale.to_f / r.new_area) * 0.01).round(2)
      else
        Float::NAN
      end
      { province: r.province, new_area_rate: new_area_rate }
    end

    @new_area_省市 = province_new_area(@sum_scope)
    @year_rate_省市 = province_area_rates(@new_area_rates)

    sum_previous_cp = filter_contract_price_scope(
      Date.civil(@beginning_of_year.year - 1).beginning_of_year,
      (@end_of_month - 1.year),
      @orgs_options, @service_phase)

    previous_year = (@end_of_month - 1.year)
    @sum_previous_scope = if previous_year.year == 2017 && previous_year.month == 2
      filter_province_new_area_scope(Date.new(2017, 3, 31))
    else
      filter_province_new_area_scope(previous_year)
    end

    @total_previous_new_area = 0
    @total_previous_scale = 0
    @previous_new_area_rates = @sum_previous_scope.collect do |previous_r|
      cp_pr = sum_previous_cp.find { |pr| pr.provincename == previous_r.province }
      @total_previous_new_area += previous_r.new_area.to_i
      @total_previous_scale += cp_pr&.scale.to_f
      previous_new_area_rate = ((cp_pr&.scale.to_f / previous_r&.new_area) * 0.01).round(2)
      { province: previous_r.province, new_area_rate: previous_new_area_rate }
    end
    @previous_year_rate_省市 = province_area_rates(@previous_new_area_rates)
  end

  private

    def filter_province_new_area_scope(month)
      policy_scope(Bi::ProvinceNewArea).select('province, SUM(new_area) new_area')
        .group('province')
        .where(date: month.beginning_of_month..month.end_of_month)
        .order('SUM(new_area) DESC')
    end

    def province_new_area(sum_scope)
      sum_台湾 = sum_scope.find { |c| c.province == '台湾省' }&.new_area || 0
      sum_河北 = sum_scope.find { |c| c.province == '河北省' }&.new_area || 0
      sum_山西 = sum_scope.find { |c| c.province == '山西省' }&.new_area || 0
      sum_内蒙古 = sum_scope.find { |c| c.province == '内蒙古自治区' }&.new_area || 0
      sum_辽宁 = sum_scope.find { |c| c.province == '辽宁省' }&.new_area || 0
      sum_吉林 = sum_scope.find { |c| c.province == '吉林省' }&.new_area || 0
      sum_黑龙江 = sum_scope.find { |c| c.province == '黑龙江省' }&.new_area || 0

      sum_江苏 = sum_scope.find { |c| c.province == '江苏省' }&.new_area || 0
      sum_浙江 = sum_scope.find { |c| c.province == '浙江省' }&.new_area || 0
      sum_安徽 = sum_scope.find { |c| c.province == '安徽省' }&.new_area || 0
      sum_福建 = sum_scope.find { |c| c.province == '福建省' }&.new_area || 0
      sum_江西 = sum_scope.find { |c| c.province == '江西省' }&.new_area || 0
      sum_山东 = sum_scope.find { |c| c.province == '山东省' }&.new_area || 0
      sum_河南 = sum_scope.find { |c| c.province == '河南省' }&.new_area || 0

      sum_湖北 = sum_scope.find { |c| c.province == '湖北省' }&.new_area || 0
      sum_湖南 = sum_scope.find { |c| c.province == '湖南省' }&.new_area || 0
      sum_广东 = sum_scope.find { |c| c.province == '广东省' }&.new_area || 0
      sum_广西 = sum_scope.find { |c| c.province == '广西壮族自治区' }&.new_area || 0
      sum_海南 = sum_scope.find { |c| c.province == '海南省' }&.new_area || 0
      sum_四川 = sum_scope.find { |c| c.province == '四川省' }&.new_area || 0
      sum_贵州 = sum_scope.find { |c| c.province == '贵州省' }&.new_area || 0

      sum_云南 = sum_scope.find { |c| c.province == '云南省' }&.new_area || 0
      sum_西藏 = sum_scope.find { |c| c.province == '西藏自治区' }&.new_area || 0
      sum_陕西 = sum_scope.find { |c| c.province == '陕西省' }&.new_area || 0
      sum_甘肃 = sum_scope.find { |c| c.province == '甘肃省' }&.new_area || 0
      sum_青海 = sum_scope.find { |c| c.province == '青海省' }&.new_area || 0
      sum_宁夏 = sum_scope.find { |c| c.province == '宁夏回族自治区' }&.new_area || 0
      sum_新疆 = sum_scope.find { |c| c.province == '新疆维吾尔自治区' }&.new_area || 0

      sum_北京 = sum_scope.find { |c| c.province == '北京市' }&.new_area || 0
      sum_天津 = sum_scope.find { |c| c.province == '天津市' }&.new_area || 0
      sum_上海 = sum_scope.find { |c| c.province == '上海市' }&.new_area || 0
      sum_重庆 = sum_scope.find { |c| c.province == '重庆市' }&.new_area || 0
      sum_香港 = sum_scope.find { |c| c.province == '香港特别行政区' }&.new_area || 0
      sum_澳门 = sum_scope.find { |c| c.province == '澳门特别行政区' }&.new_area || 0

      # There is no place to drawing c.province == '其他' and '海外'

      # The return sequence should same as JS function mapProvinceSum2MapData
      [ sum_台湾, sum_河北, sum_山西, sum_内蒙古, sum_辽宁, sum_吉林, sum_黑龙江,
               sum_江苏, sum_浙江, sum_安徽, sum_福建, sum_江西, sum_山东, sum_河南,
               sum_湖北, sum_湖南, sum_广东, sum_广西, sum_海南, sum_四川, sum_贵州,
               sum_云南, sum_西藏, sum_陕西, sum_甘肃, sum_青海, sum_宁夏, sum_新疆,
               sum_北京, sum_天津, sum_上海, sum_重庆, sum_香港, sum_澳门 ]
    end

    def province_area_rates(area_rates)
      sum_台湾 = area_rates.find { |c| c[:province] == '台湾省' }&.fetch(:new_area_rate, nil) || 0
      sum_河北 = area_rates.find { |c| c[:province] == '河北省' }&.fetch(:new_area_rate, nil) || 0
      sum_山西 = area_rates.find { |c| c[:province] == '山西省' }&.fetch(:new_area_rate, nil) || 0
      sum_内蒙古 = area_rates.find { |c| c[:province] == '内蒙古自治区' }&.fetch(:new_area_rate, nil) || 0
      sum_辽宁 = area_rates.find { |c| c[:province] == '辽宁省' }&.fetch(:new_area_rate, nil) || 0
      sum_吉林 = area_rates.find { |c| c[:province] == '吉林省' }&.fetch(:new_area_rate, nil) || 0
      sum_黑龙江 = area_rates.find { |c| c[:province] == '黑龙江省' }&.fetch(:new_area_rate, nil) || 0

      sum_江苏 = area_rates.find { |c| c[:province] == '江苏省' }&.fetch(:new_area_rate, nil) || 0
      sum_浙江 = area_rates.find { |c| c[:province] == '浙江省' }&.fetch(:new_area_rate, nil) || 0
      sum_安徽 = area_rates.find { |c| c[:province] == '安徽省' }&.fetch(:new_area_rate, nil) || 0
      sum_福建 = area_rates.find { |c| c[:province] == '福建省' }&.fetch(:new_area_rate, nil) || 0
      sum_江西 = area_rates.find { |c| c[:province] == '江西省' }&.fetch(:new_area_rate, nil) || 0
      sum_山东 = area_rates.find { |c| c[:province] == '山东省' }&.fetch(:new_area_rate, nil) || 0
      sum_河南 = area_rates.find { |c| c[:province] == '河南省' }&.fetch(:new_area_rate, nil) || 0

      sum_湖北 = area_rates.find { |c| c[:province] == '湖北省' }&.fetch(:new_area_rate, nil) || 0
      sum_湖南 = area_rates.find { |c| c[:province] == '湖南省' }&.fetch(:new_area_rate, nil) || 0
      sum_广东 = area_rates.find { |c| c[:province] == '广东省' }&.fetch(:new_area_rate, nil) || 0
      sum_广西 = area_rates.find { |c| c[:province] == '广西壮族自治区' }&.fetch(:new_area_rate, nil) || 0
      sum_海南 = area_rates.find { |c| c[:province] == '海南省' }&.fetch(:new_area_rate, nil) || 0
      sum_四川 = area_rates.find { |c| c[:province] == '四川省' }&.fetch(:new_area_rate, nil) || 0
      sum_贵州 = area_rates.find { |c| c[:province] == '贵州省' }&.fetch(:new_area_rate, nil) || 0

      sum_云南 = area_rates.find { |c| c[:province] == '云南省' }&.fetch(:new_area_rate, nil) || 0
      sum_西藏 = area_rates.find { |c| c[:province] == '西藏自治区' }&.fetch(:new_area_rate, nil) || 0
      sum_陕西 = area_rates.find { |c| c[:province] == '陕西省' }&.fetch(:new_area_rate, nil) || 0
      sum_甘肃 = area_rates.find { |c| c[:province] == '甘肃省' }&.fetch(:new_area_rate, nil) || 0
      sum_青海 = area_rates.find { |c| c[:province] == '青海省' }&.fetch(:new_area_rate, nil) || 0
      sum_宁夏 = area_rates.find { |c| c[:province] == '宁夏回族自治区' }&.fetch(:new_area_rate, nil) || 0
      sum_新疆 = area_rates.find { |c| c[:province] == '新疆维吾尔自治区' }&.fetch(:new_area_rate, nil) || 0

      sum_北京 = area_rates.find { |c| c[:province] == '北京市' }&.fetch(:new_area_rate, nil) || 0
      sum_天津 = area_rates.find { |c| c[:province] == '天津市' }&.fetch(:new_area_rate, nil) || 0
      sum_上海 = area_rates.find { |c| c[:province] == '上海市' }&.fetch(:new_area_rate, nil) || 0
      sum_重庆 = area_rates.find { |c| c[:province] == '重庆市' }&.fetch(:new_area_rate, nil) || 0
      sum_香港 = area_rates.find { |c| c[:province] == '香港特别行政区' }&.fetch(:new_area_rate, nil) || 0
      sum_澳门 = area_rates.find { |c| c[:province] == '澳门特别行政区' }&.fetch(:new_area_rate, nil) || 0

      # There is no place to drawing c[:province] == '其他' and '海外'

      # The return sequence should same as JS function mapProvinceSum2MapData
      [ sum_台湾, sum_河北, sum_山西, sum_内蒙古, sum_辽宁, sum_吉林, sum_黑龙江,
               sum_江苏, sum_浙江, sum_安徽, sum_福建, sum_江西, sum_山东, sum_河南,
               sum_湖北, sum_湖南, sum_广东, sum_广西, sum_海南, sum_四川, sum_贵州,
               sum_云南, sum_西藏, sum_陕西, sum_甘肃, sum_青海, sum_宁夏, sum_新疆,
               sum_北京, sum_天津, sum_上海, sum_重庆, sum_香港, sum_澳门 ]
    end

    def filter_contract_price_scope(beginning_of_year, end_of_year, orgs_options, service_phase)
      # Debug SELECT salescontractcode, salescontractname, buildinggenrename, scale
      cp = Bi::ContractPrice.where("stagename like '%深化方案%'").or(Bi::ContractPrice.where("stagename like '%施工图设计%'")).or(Bi::ContractPrice.where("stagename like '%全过程%'"))
      cp = cp.where(contractstatusname: ['已归档', '合同完成'],
                    projectbigstagename: ['前端', '后端', '全过程'],
                    projectgenername: ['公建', '住宅'],
                    unitsname: '元/平米',
                    contractpropertyname: '主合同',
                    operationgenrename: '土建')
        .where.not(buildinggenrename: '地下车库（非人防）')
      sum_scope = policy_scope(cp, :overview_resolve)
      cateogries_4 = case service_phase
                     when '前端'
                       %w[住宅方案 公建方案]
                     when '后端'
                       %w[住宅施工图 公建施工图]
      end

      sum_scope = case cateogries_4
                  when %w[住宅方案]
                    sum_scope.where(projectbigstagename: ['前端', '全过程'], projectgenername: '住宅')
                  when %w[住宅施工图]
                    sum_scope.where(projectbigstagename: ['后端', '全过程'], projectgenername: '住宅')
                  when %w[公建方案]
                    sum_scope.where(projectbigstagename: ['前端', '全过程'], projectgenername: '公建')
                  when %w[公建施工图]
                    sum_scope.where(projectbigstagename: ['后端', '全过程'], projectgenername: '公建')
                  when %w[住宅方案 住宅施工图]
                    sum_scope.where(projectbigstagename: ['前端', '后端', '全过程'], projectgenername: '住宅')
                  when %w[住宅方案 公建方案]
                    sum_scope.where(projectbigstagename: ['前端', '全过程'], projectgenername: ['住宅', '公建'])
                  when %w[住宅方案 公建施工图]
                    sum_scope.where(projectbigstagename: ['前端', '全过程'], projectgenername: '住宅') \
                      .or(sum_scope.where(projectbigstagename: ['后端', '全过程'], projectgenername: '公建'))
                  when %w[住宅施工图 公建方案]
                    sum_scope.where(projectbigstagename: ['后端', '全过程'], projectgenername: '住宅') \
                      .or(sum_scope.where(projectbigstagename: ['前端', '全过程'], projectgenername: '公建'))
                  when %w[住宅施工图 公建施工图]
                    sum_scope.where(projectbigstagename: ['后端', '全过程'], projectgenername: ['住宅', '公建'])
                  when %w[公建方案 公建施工图]
                    sum_scope.where(projectbigstagename: ['前端', '后端', '全过程'], projectgenername: '公建')
                  when %w[住宅方案 住宅施工图 公建方案]
                    sum_scope.where(projectbigstagename: ['前端', '后端', '全过程'], projectgenername: '住宅') \
                      .or(sum_scope.where(projectbigstagename: ['前端', '全过程'], projectgenername: '公建'))
                  when %w[住宅方案 公建方案 公建施工图]
                    sum_scope.where(projectbigstagename: ['前端', '全过程'], projectgenername: '住宅') \
                      .or(sum_scope.where(projectbigstagename: ['前端', '后端', '全过程'], projectgenername: '公建'))
                  when %w[住宅施工图 公建方案 公建施工图]
                    sum_scope.where(projectbigstagename: ['后端', '全过程'], projectgenername: '住宅') \
                      .or(sum_scope.where(projectbigstagename: ['前端', '后端', '全过程'], projectgenername: '公建'))
                  when %w[住宅方案 住宅施工图 公建施工图]
                    sum_scope.where(projectbigstagename: ['前端', '后端', '全过程'], projectgenername: '住宅') \
                      .or(sum_scope.where(projectbigstagename: ['后端', '全过程'], projectgenername: '公建'))
                  when %w[住宅方案 住宅施工图 公建方案 公建施工图]
                    sum_scope.where(projectbigstagename: ['前端', '后端', '全过程'], projectgenername: ['住宅', '公建'])
                  else
                    raise 'No such combine!'
      end

      sum_scope.select('provincename, SUM(scale) scale')
        .group('provincename')
        .where(businessltdcode: orgs_options)
        .where('scale > 0')
        .where(filingtime: beginning_of_year..end_of_year)
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
