# frozen_string_literal: true

class Report::CrmYearReportsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::CrmYearReport
    @all_month_names = policy_scope(Bi::CrmClientSum).all_month_names
    @month_name = params[:month_name] || @all_month_names.first
    current_month_begin = Date.parse(@month_name).beginning_of_month
    last_year_begin = (Date.parse(@month_name) - 1.year).end_of_year.beginning_of_month
    @orgs_options = params[:orgs]

    respond_to do |format|
      format.html do
        prepare_meta_tags title: t('.title')

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

        @orgs_options = all_company_orgcodes if @orgs_options.blank?

        @years = @data.collect(&:year)
        @top20s = @data.collect { |d| (d.top20 / 100_0000.0).round(1) }
        @top20to50s = @data.collect { |d| (d.top20to50 / 100_0000.0).round(1) }
        @gt50s = @data.collect { |d| (d.gt50 / 100_0000.0).round(1) }
        @others = @data.collect { |d| (d.others / 100_0000.0).round(1) }
      end
      format.json do
        str_orgs = ActiveRecord::Base.sanitize_sql(@orgs_options.collect { |d| "'#{d}'" }.join(','))
        ar_crm_client_sum = policy_scope(Bi::CrmClientSum)
          .joins("LEFT JOIN (select crmcode, sum(realamounttotal)  heji_a FROM CRM_SACONTRACT where savedate='#{current_month_begin}' AND businessltdcode in (#{str_orgs}) group by crmcode) A ON CRM_CLIENT_SUM.crmcode=A.crmcode")
          .joins("LEFT JOIN (select crmcode, sum(realamounttotal)  heji_last_b FROM CRM_SACONTRACT where savedate='#{last_year_begin}' AND businessltdcode in (#{str_orgs}) group by crmcode) B ON CRM_CLIENT_SUM.crmcode=B.crmcode")
          .joins("LEFT JOIN (select crmcode, sum(frontpart) designvalue_c FROM CRM_SACONTRACTPRICE where savedate='#{current_month_begin}' AND businessltdcode in (#{str_orgs}) and projectstage='前端' group by crmcode) C ON CRM_CLIENT_SUM.crmcode=C.crmcode")
          .joins("LEFT JOIN (select crmcode, sum(rearpart)  constructionvalue_d FROM CRM_SACONTRACTPRICE where savedate='#{current_month_begin}' AND businessltdcode in (#{str_orgs}) and projectstage='后端' group by crmcode) D ON CRM_CLIENT_SUM.crmcode=D.crmcode")
          .joins("LEFT JOIN (select crmcode, sum(parttotal) fullvalue_e FROM CRM_SACONTRACTPRICE where savedate='#{current_month_begin}' AND businessltdcode in (#{str_orgs}) and projectstage='全过程' group by crmcode) E ON CRM_CLIENT_SUM.crmcode=E.crmcode")
          .select('`CRM_CLIENT_SUM`.crmcode, `CRM_CLIENT_SUM`.cricrank, `CRM_CLIENT_SUM`.clientproperty, A.heji_a, B.heji_last_b, `CRM_CLIENT_SUM`.heji, `CRM_CLIENT_SUM`.heji_last, `CRM_CLIENT_SUM`.heji_per, `CRM_CLIENT_SUM`.topthreegroup, C.designvalue_c, D.constructionvalue_d, E.fullvalue_e')
        render json: Report::CrmYearReportDatatable.new(params,
          crm_client_sum: ar_crm_client_sum,
          month_name: @month_name,
          view_context: view_context)
      end
    end
  end

  def export
    end_of_month = Date.parse(params[:month_name]).end_of_month
    detail_data = policy_scope(Bi::CrmClientSum)
      .joins("LEFT JOIN (select crmcode, sum(realamounttotal)  heji_a FROM CRM_SACONTRACT where savedate='2021-05-31' group by crmcode) A ON CRM_CLIENT_SUM.crmcode=A.crmcode")
      .joins("LEFT JOIN (select crmcode, sum(realamounttotal)  heji_last_b FROM CRM_SACONTRACT where savedate='2020-12-31' group by crmcode) B ON CRM_CLIENT_SUM.crmcode=B.crmcode")
      .joins("LEFT JOIN (select crmcode, sum(frontpart) designvalue_c FROM CRM_SACONTRACTPRICE where savedate='2021-05-31' and projectstage='前端' group by crmcode) C ON CRM_CLIENT_SUM.crmcode=C.crmcode")
      .joins("LEFT JOIN (select crmcode, sum(rearpart)  constructionvalue_d FROM CRM_SACONTRACTPRICE where savedate='2021-05-31' and projectstage='后端' group by crmcode) D ON CRM_CLIENT_SUM.crmcode=D.crmcode")
      .joins("LEFT JOIN (select crmcode, sum(parttotal) fullvalue_e FROM CRM_SACONTRACTPRICE where savedate='2021-05-31' and projectstage='全过程' group by crmcode) E ON CRM_CLIENT_SUM.crmcode=E.crmcode")
      .select('`CRM_CLIENT_SUM`.crmcode, `CRM_CLIENT_SUM`.cricrank, `CRM_CLIENT_SUM`.clientproperty, A.heji_a, B.heji_last_b, `CRM_CLIENT_SUM`.heji, `CRM_CLIENT_SUM`.heji_last, `CRM_CLIENT_SUM`.heji_per, `CRM_CLIENT_SUM`.topthreegroup, C.designvalue_c, D.constructionvalue_d, E.fullvalue_e')
      .where(savedate: end_of_month)

    render_csv_header "#{end_of_month.year}年#{end_of_month.month}月客户生产合同额及占比明细"
    csv_res = CSV.generate do |csv|
      csv << [
        I18n.t('report.crm_year_reports.show.table.customer_group'),
        I18n.t('report.crm_year_reports.show.table.kerrey_trading_area_ranking'),
        I18n.t('report.crm_year_reports.show.table.customer_ownership'),
        I18n.t('report.crm_year_reports.show.table.contract_value_last_year'),
        I18n.t('report.crm_year_reports.show.table.contract_value_this_year'),
        I18n.t('report.crm_year_reports.show.table.group_contract_value_last_year'),
        I18n.t('report.crm_year_reports.show.table.group_contract_value_this_year'),

        I18n.t('report.crm_year_reports.show.table.the_top_three_teams_in_cooperation'),
        I18n.t('report.crm_year_reports.show.table.scheme_production_contract_value_at_each_stage'),
        I18n.t('report.crm_year_reports.show.table.construction_drawing_production_contract_value_at_each_stage'),
        I18n.t('report.crm_year_reports.show.table.total_contract_value_of_the_group_percent'),
        I18n.t('report.crm_year_reports.show.table.whole_process_production_contract_value_at_each_stage'),

        I18n.t('report.crm_year_reports.show.table.average_contract_value_of_single_project_in_the_past_year'),
        I18n.t('report.crm_year_reports.show.table.average_scale_of_single_project_in_the_past_year'),
        I18n.t('report.crm_year_reports.show.table.nearly_one_year_contract_average_contract_period'),
        I18n.t('report.crm_year_reports.show.table.proportion_of_contract_amount_modification_fee'),
        I18n.t('report.crm_year_reports.show.table.proportion_of_labor_cost_of_bidding_land_acquisition')
      ]
      detail_data.each_with_index do |dd, index|
        values = []
        values << Bi::CrmClientInfo.crm_short_names.fetch(dd.crmcode, nil)
        values << dd.cricrank&.round(0)
        values << dd.clientproperty
        values << (dd.heji_last_b.to_f / 10000.0).round(0)
        values << (dd.heji_a.to_f / 10000.0).round(0)
        values << (dd.heji_last.to_f / 10000.0).round(0)
        values << (dd.heji.to_f / 10000.0).round(0)

        values << dd.topthreegroup
        values << (dd.designvalue_c.to_f / 10000.0).round(0)
        values << (dd.constructionvalue_d.to_f / 10000.0).round(0)
        values << (dd.heji_per.to_f * 100.0).round(1)
        values << (dd.fullvalue_e.to_f / 10000.0).round(0)

        values << (Bi::CrmClientOneYear.by_crmcode.fetch(dd.crmcode, nil)&.fetch(:avgamount, 0).to_f / 10000.0).round(0)
        values << (Bi::CrmClientOneYear.by_crmcode.fetch(dd.crmcode, nil)&.fetch(:avgarea, 0).to_f / 10000.0).round(0)
        values << Bi::CrmClientOneYear.by_crmcode.fetch(dd.crmcode, nil)&.fetch(:avgsignday, 0)&.round(0)
        values << (Bi::CrmClientOneYear.by_crmcode.fetch(dd.crmcode, nil)&.fetch(:contractalter, 0).to_f * 100.0).round(1)
        values << (Bi::CrmClientOneYear.by_crmcode.fetch(dd.crmcode, nil)&.fetch(:landhrcost, 0).to_f * 100.0).round(1)
        csv << values
      end
    end
    send_data "\xEF\xBB\xBF#{csv_res}", filename: "#{end_of_month.year}年#{end_of_month.month}月客户生产合同额及占比明细.csv"
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

  def drill_down_dept_value
    @crmcode = params[:crmcode]
    year = params[:year]
    @plan_values = policy_scope(Bi::VCrmSacontract)
      .where(crmcode: @crmcode, cricyear: year)
  end

  def drill_down_top_group
    crmcode = params[:crmcode]
    @year = params[:year]
    @plan_values = policy_scope(Bi::ContractPrice).where(crmcode: crmcode, cricyear: @year)
      .group(:crmbusiunitcode, :crmcode, :crmshort, :crmbusiunitname)
      .order('SUM(discounttotal) DESC')
      .select('crmbusiunitcode, crmcode, crmshort, crmbusiunitname, SUM(discounttotal) discounttotal')
  end

  def drill_down_group_detail
    crmbusiunitcode = params[:crmbusiunitcode]
    crmcode = params[:crmcode]
    year = params[:year]
    @plan_values = policy_scope(Bi::ContractPrice).where(crmbusiunitcode: crmbusiunitcode, crmcode: crmcode, cricyear: year)
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
