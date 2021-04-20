# frozen_string_literal: true

class Report::CrmYearReportsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @orgs_options = params[:orgs]

    all_company_orgcodes = policy_scope(Bi::CrmYearReport)
      .select(:orgcode, :"ORG_ORDER.org_order")
      .joins('INNER JOIN ORG_ORDER on ORG_ORDER.org_code = CRM_YEAR_REPORT.orgcode')
      .order('ORG_ORDER.org_order ASC')
      .pluck(:orgcode).uniq
    all_company_short_names = all_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @organization_options = all_company_short_names.zip(all_company_orgcodes)
    data = policy_scope(Bi::CrmYearReport)
    @data = if @orgs_options.present?
      data.where(orgcode: @orgs_options)
    else
      data
    end.select('year, sum(top20) top20, sum(top20to50) top20to50, sum(gt50) gt50, sum(others) others')
       .group(:year)
       .order(:year)

    @years = @data.collect(&:year)
    @top20s = @data.collect { |d| (d.top20 / 100_0000.0).round(1) }
    @top20to50s = @data.collect { |d| (d.top20to50 / 100_0000.0).round(1) }
    @gt50s = @data.collect { |d| (d.gt50 / 100_0000.0).round(1) }
    @others = @data.collect { |d| (d.others / 100_0000.0).round(1) }
  end

  def drill_down
    @year = params[:year]
    @series_name = params[:series_name]

    category = case @series_name
               when 'TOP 20 房企'
                 '20'
               when 'TOP 20-50 房企'
                 '50'
               when '非 TOP 50 大客户'
                 '100'
               when '其他'
                 '其他'
    end
    @crm_tops = Bi::CrmTop50.where(年份: @year, 客户分类: category).order(:排名)
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.report.header'),
        link: report_root_path },
      { text: t('layouts.sidebar.operation.crm_year_report'),
        link: report_crm_year_report_path }]
    end
end
