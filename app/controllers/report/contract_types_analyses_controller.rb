# frozen_string_literal: true

class Report::ContractTypesAnalysesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_month_names = policy_scope(Bi::ContractPrice).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    end_of_year_month = Date.parse(@month_name).end_of_month
    @beginning_of_year = end_of_year_month.beginning_of_year

    data = policy_scope(Bi::ContractPrice)
      .group(:businessltdcode)
      .select('businessltdcode, SUM(realamounttotal) realamounttotal')
      .order('SUM(realamounttotal) DESC')
      .where(filingtime: @beginning_of_year..end_of_year_month)

    @orgs_options = params[:orgs]

    all_company_orgcodes = data.collect(&:businessltdcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)

    @orgs_options = all_company_orgcodes if @orgs_options.blank?
    data.where(businessltdcode: @orgs_options)

    contract_price_方案 = data.where(projectstage: '前端')
    contract_price_施工图 = data.where(projectstage: '后端')

    contract_price_方案_公司 = contract_price_方案.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c.businessltdcode, c.businessltdcode) }
    contract_price_方案_合同总金额 = contract_price_方案.collect(&:realamounttotal)
    total_contract_price_方案_合同总金额 = contract_price_方案_合同总金额.sum
    first_10_contract_price_方案_合同总金额 = contract_price_方案_合同总金额[0..9]

    @contract_price_方案_公司 = contract_price_方案_公司[0..9].append('其他')
    @contract_price_方案_合同总金额 = first_10_contract_price_方案_合同总金额.append(total_contract_price_方案_合同总金额 - first_10_contract_price_方案_合同总金额.sum)
    @contract_price_方案_合同总金额 = @contract_price_方案_合同总金额.map { |d| (d/10000_00.0).round(2) }


    contract_price_施工图_公司 = contract_price_施工图.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c.businessltdcode, c.businessltdcode) }
    contract_price_施工图_合同总金额 = contract_price_施工图.collect(&:realamounttotal)
    total_contract_price_施工图_合同总金额 = contract_price_施工图_合同总金额.sum
    first_10_contract_price_施工图_合同总金额 = contract_price_施工图_合同总金额[0..9]
    @contract_price_施工图_公司 = contract_price_施工图_公司[0..9].append('其他')
    @contract_price_施工图_合同总金额 = first_10_contract_price_施工图_合同总金额.append(total_contract_price_施工图_合同总金额 - first_10_contract_price_施工图_合同总金额.sum)
    @contract_price_施工图_合同总金额 = @contract_price_施工图_合同总金额.map { |d| (d/10000_00.0).round(2) }

    @years_category, @years_sum_住宅方案, @years_sum_住宅施工图, @years_sum_公建方案, @years_sum_公建施工图 \
      = 住宅公建_contract_price(2016, 2020, @orgs_options)
  end

  private

    def 住宅公建_contract_price(begin_of_year, end_of_year, orgs_options)
      sum_scope = policy_scope(Bi::ContractPrice)
        .select('YEAR(filingtime) year_name, projectstage, projecttype, SUM(realamounttotal) realamounttotal')
        .group('YEAR(filingtime), projectstage, projecttype')
        .where('YEAR(filingtime) >= ?', begin_of_year)
        .where('YEAR(filingtime) <= ?', end_of_year)
        .where(businessltdcode: orgs_options)
      years_name = (begin_of_year..end_of_year).to_a
      years_sum_住宅方案 = []
      years_sum_住宅施工图 = []
      years_sum_公建方案 = []
      years_sum_公建施工图 = []
      years_name.each do |year|
        years_sum_住宅方案 << sum_scope.find { |c| c.year_name == year && c.projectstage == '前端' && c.projecttype == '土建住宅' }&.realamounttotal
        years_sum_住宅施工图 << sum_scope.find { |c| c.year_name == year && c.projectstage == '后端' && c.projecttype == '土建住宅' }&.realamounttotal
        years_sum_公建方案 << sum_scope.find { |c| c.year_name == year && c.projectstage == '前端' && c.projecttype == '土建公建' }&.realamounttotal
        years_sum_公建施工图 << sum_scope.find { |c| c.year_name == year && c.projectstage == '后端' && c.projecttype == '土建公建' }&.realamounttotal
      end
      years_sum_住宅方案 = years_sum_住宅方案.map { |d| (d/10000_00.0).round(2) }
      years_sum_住宅施工图 = years_sum_住宅施工图.map { |d| (d/10000_00.0).round(2) }
      years_sum_公建方案 = years_sum_公建方案.map { |d| (d/10000_00.0).round(2) }
      years_sum_公建施工图 = years_sum_公建施工图.map { |d| (d/10000_00.0).round(2) }
      return [years_name, years_sum_住宅方案, years_sum_住宅施工图, years_sum_公建方案, years_sum_公建施工图]
    end


    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.contract_types_analysis'),
        link: report_contract_types_analysis_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
