# frozen_string_literal: true

class Report::ContractTypesAnalysesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    @all_year_names = Bi::ContractPrice.all_year_names
    @year_name = params[:year_name]&.strip || @all_year_names.first

    data = Bi::ContractPrice
      .group(:businessltdcode)
      .select('businessltdcode, SUM(realamounttotal) realamounttotal')
      .order('SUM(realamounttotal) DESC')

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

    contract_price_施工图_公司 = contract_price_施工图.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c.businessltdcode, c.businessltdcode) }
    contract_price_施工图_合同总金额 = contract_price_施工图.collect(&:realamounttotal)
    total_contract_price_施工图_合同总金额 = contract_price_施工图_合同总金额.sum
    first_10_contract_price_施工图_合同总金额 = contract_price_施工图_合同总金额[0..9]
    @contract_price_施工图_公司 = contract_price_施工图_公司[0..9].append('其他')
    @contract_price_施工图_合同总金额 = first_10_contract_price_施工图_合同总金额.append(total_contract_price_施工图_合同总金额 - first_10_contract_price_施工图_合同总金额.sum)

    sum_scope = Bi::ContractPrice.select('projectstage, projecttype, SUM(realamounttotal) realamounttotal').group(:projectstage, :projecttype)
    sum_住宅方案 = sum_scope.find { |c| c.projectstage == '前端' && c.projecttype == '土建住宅' }
    sum_住宅施工图 = sum_scope.find { |c| c.projectstage == '后端' && c.projecttype == '土建住宅' }
    sum_公建方案 = sum_scope.find { |c| c.projectstage == '前端' && c.projecttype == '土建公建' }
    sum_公建施工图 = sum_scope.find { |c| c.projectstage == '后端' && c.projecttype == '土建公建' }
    @contract_price_住宅公建 = %w[住宅方案 住宅施工图 公建方案 公建施工图]
    @contract_price_住宅公建总金额 = [sum_住宅方案.realamounttotal, sum_住宅施工图.realamounttotal, sum_公建方案.realamounttotal, sum_公建施工图.realamounttotal]
  end

  private

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
