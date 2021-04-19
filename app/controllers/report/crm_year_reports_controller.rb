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
        link: report_root_path }]
    end
end
