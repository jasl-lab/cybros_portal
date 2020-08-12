# frozen_string_literal: true

class Report::PredictContractsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_drill_down_variables, only: %i[opportunity_detail_drill_down signing_detail_drill_down], if: -> { request.format.js? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def fill_dept_names
  end

  def show
    @all_month_names = policy_scope(Bi::TrackContract, :group_resolve).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    raise Pundit::NotAuthorizedError if @month_name.nil?
    end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_month = Date.parse(@month_name).beginning_of_month
    @dept_codes_as_options = params[:depts]

    @last_available_date = policy_scope(Bi::TrackContract, :group_resolve).where(date: beginning_of_month..end_of_month).order(date: :desc).first.date
    @select_company_short_names = policy_scope(Bi::TrackContract, :group_resolve).available_company_names(@last_available_date)
    @selected_org_code = params[:org_code]&.strip || current_user.can_access_org_codes.first || current_user.user_company_orgcode

    data = policy_scope(Bi::TrackContract, :group_resolve)
      .where(orgcode: @selected_org_code)
      .where(date: @last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where("ORG_REPORT_DEPT_ORDER.开始时间 <= ?", @last_available_date)
      .where("ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?", @last_available_date)
      .joins("INNER JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = TRACK_CONTRACT.deptcode")
      .select("ORG_REPORT_DEPT_ORDER.部门排名, TRACK_CONTRACT.deptcode, SUM(contractconvert) contractconvert, SUM(convertrealamount) convertrealamount")
      .order("ORG_REPORT_DEPT_ORDER.部门排名, TRACK_CONTRACT.deptcode")
      .group("ORG_REPORT_DEPT_ORDER.部门排名, TRACK_CONTRACT.deptcode")
      .having("contractconvert > 0 OR convertrealamount > 0")

    @dept_codes_as_options = data.collect(&:deptcode) if @dept_codes_as_options.blank?
    data = data.where(deptcode: @dept_codes_as_options)

    @dept_names = @dept_codes_as_options.collect do |c|
      Bi::PkCodeName.mapping2deptcode.fetch(c, c)
    end
    @department_options = @dept_names.zip(@dept_codes_as_options)

    @contract_convert = @dept_codes_as_options.collect do |dept_code|
      d = data.find { |t| t.deptcode == dept_code }
      ((d&.contractconvert || 0) / 10000.to_f).round(0)
    end
    @convert_real_amount = @dept_codes_as_options.collect do |dept_code|
      d = data.find { |t| t.deptcode == dept_code }
      ((d&.convertrealamount || 0) / 10000.to_f).round(0)
    end
    @contract_convert_totals = @contract_convert.zip(@convert_real_amount).map { |d| d[0] + d[1] }
  end

  def opportunity_detail_drill_down
    dept_code = params[:department_code].strip
    @tcod = policy_scope(Bi::TrackContractOpportunityDetail)
      .where(date: @last_available_date)
      .where(deptcode: dept_code)
      .where('contractamount > 0')
    render
  end

  def signing_detail_drill_down
    dept_code = params[:department_code].strip
    @tcsd = policy_scope(Bi::TrackContractSigningDetail)
      .where(date: @last_available_date)
      .where(deptcode: dept_code)
      .where("convertrealamount > 0")
    render
  end

  private

    def set_drill_down_variables
      @dept_name = params[:department_name].strip
      @drill_down_subtitle = t(".subtitle")

      month_name = params[:month_name]&.strip
      end_of_month = Date.parse(month_name).end_of_month
      beginning_of_month = Date.parse(month_name).beginning_of_month

      @last_available_date = policy_scope(Bi::TrackContract).where(date: beginning_of_month..end_of_month).order(date: :desc).first.date
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.predict_contract'),
        link: report_predict_contract_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
