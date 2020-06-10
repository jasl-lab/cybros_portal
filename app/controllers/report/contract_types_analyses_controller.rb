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

    @orgs_options = params[:orgs]

    all_company_orgcodes = data.collect(&:businessltdcode)
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)

    @orgs_options = all_company_orgcodes if @orgs_options.blank?
    data.where(businessltdcode: @orgs_options)

    contract_price_方案 = data.where(projectstage: '前端')
    contract_price_施工图 = data.where(projectstage: '后端')

    @contract_price_方案_公司 = contract_price_方案.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c.businessltdcode, c.businessltdcode) }
    @contract_price_方案_合同总金额 = contract_price_方案.collect(&:realamounttotal)

    @contract_price_施工图_公司 = contract_price_施工图.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c.businessltdcode, c.businessltdcode) }
    @contract_price_施工图_合同总金额 = contract_price_施工图.collect(&:realamounttotal)
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
