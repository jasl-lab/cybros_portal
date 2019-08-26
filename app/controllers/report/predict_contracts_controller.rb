# frozen_string_literal: true

class Report::PredictContractsController < Report::BaseController
  before_action :authenticate_user!, unless: -> { params[:in_iframe].present? }, only: [:show]
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_drill_down_variables, only: %i[opportunity_detail_drill_down signing_detail_drill_down], if: -> { request.format.js? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    @all_month_names = policy_scope(Bi::TrackContract).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @last_available_date = policy_scope(Bi::TrackContract).where(date: beginning_of_month..end_of_month).order(date: :desc).first.date

    data = policy_scope(Bi::TrackContract).where(date: @last_available_date)
      .select("businessdeptcode, SUM(contractconvert) contractconvert, SUM(convertrealamount) convertrealamount")
      .group(:businessdeptcode)

    data = data.where(businessdeptcode: params[:depts]) if params[:depts].present?
    all_business_ltd_codes = data.collect(&:businessdeptcode)
    only_have_data_dept = (Bi::ShReportDeptOrder.all_deptcodes_in_order & all_business_ltd_codes)

    @company_short_names = only_have_data_dept.collect do |c|
      long_name = Bi::PkCodeName.mapping2deptcode.fetch(c, c)
      Bi::StaffCount.company_short_names.fetch(long_name, long_name)
    end
    @department_options = @company_short_names.zip(only_have_data_dept)

    @contract_convert = only_have_data_dept.collect do |dept_code|
      d = data.find { |t| t.businessdeptcode == dept_code }
      (d.contractconvert / 10000.to_f).round(0)
    end
    @convert_real_amount = only_have_data_dept.collect do |dept_code|
      d = data.find { |t| t.businessdeptcode == dept_code }
      (d.convertrealamount / 10000.to_f).round(0)
    end
    @contract_convert_totals = @contract_convert.zip(@convert_real_amount).map { |d| d[0] + d[1] }
  end

  def opportunity_detail_drill_down
    @tcod = Bi::TrackContractOpportunityDetail
      .where(date: @last_available_date)
      .where(businessdeptcode: @dept_code)
      .where("contractconvert > 0")
    render
  end

  def signing_detail_drill_down
    @tcsd = Bi::TrackContractSigningDetail
      .where(date: @last_available_date)
      .where(businessdeptcode: @dept_code)
      .where("convertrealamount > 0")
    render
  end

  private

    def set_drill_down_variables
      @dept_name = params[:department_name].strip
      @drill_down_subtitle = t('.subtitle')
      @dept_code = Bi::ShReportDeptOrder.mapping2deptname.fetch(@dept_name, @dept_name)

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
      { text: t("layouts.sidebar.operation.predict_contract"),
        link: report_predict_contract_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
