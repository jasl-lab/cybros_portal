# frozen_string_literal: true

class Report::ContractHoldsController < Report::BaseController
  before_action :authenticate_user!, unless: -> { params[:in_iframe].present? }
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    @all_month_names = policy_scope(Bi::ContractHold).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    end_of_month = Date.parse(@month_name).end_of_month
    @last_available_date = policy_scope(Bi::ContractHold).where("date < ?", end_of_month).order(date: :desc).first.date

    data = policy_scope(Bi::ContractHold).where(date: @last_available_date)
      .select('projectitemdeptcode, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract')
      .group(:projectitemdeptcode)

    all_business_ltd_codes = data.collect(&:projectitemdeptcode)
    only_have_data_dept = (Bi::ShReportDeptOrder.all_deptcodes_in_order & all_business_ltd_codes)

    @deptnames_in_order = only_have_data_dept.collect do |c|
      long_name = Bi::PkCodeName.mapping2deptcode.fetch(c, c)
      Bi::StaffCount.company_short_names.fetch(long_name, long_name)
    end

    @biz_retent_contract = only_have_data_dept.collect do |dept_code|
      d = data.find { |c| c.projectitemdeptcode == dept_code }
      (d.busiretentcontract / 10000.to_f).round(0)
    end
    @biz_retent_no_contract = only_have_data_dept.collect do |dept_code|
      d = data.find { |c| c.projectitemdeptcode == dept_code }
      (d.busiretentnocontract.to_f / 10000.to_f).round(0)
    end

    @biz_retent_totals = @biz_retent_contract.zip(@biz_retent_no_contract).map { |d| d[0] + d[1] }
    @biz_retent_totals_sum = @biz_retent_contract.sum()
    @biz_retent_totals_sum_per_staff = @biz_retent_totals_sum /
      (@deptnames_in_order.inject(0) do |sum, deptname|
        staff_per_company = Bi::StaffCount.staff_per_company
        sum + staff_per_company.fetch(deptname, 1000)
      end).to_f
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.contract_hold"),
      link: report_contract_hold_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
