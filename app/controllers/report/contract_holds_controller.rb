# frozen_string_literal: true

class Report::ContractHoldsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    last_available_date = Bi::ContractHold.last_available_date

    data = policy_scope(Bi::ContractHold).where(date: last_available_date)
      .select('projectitemdeptcode, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract')
      .group(:projectitemdeptcode)

    all_business_ltd_codes = data.collect(&:projectitemdeptcode)
    only_have_data_dept = (Bi::ShReportDeptOrder.all_deptcodes_in_order & all_business_ltd_codes)

    @deptnames_in_order = only_have_data_dept.collect do |c|
      long_name = Bi::PkCodeName.company_long_names.fetch(c, c)
      Bi::StaffCount.company_short_names.fetch(long_name, long_name)
    end

    @biz_retent_contract = only_have_data_dept.collect do |dept_code|
      d = data.find { |d| d.projectitemdeptcode == dept_code }
      (d.busiretentcontract / 10000.to_f).round(0)
    end
    @biz_retent_no_contract = only_have_data_dept.collect do |dept_code|
      d = data.find { |d| d.projectitemdeptcode == dept_code }
      (d.busiretentnocontract / 10000.to_f).round(0)
    end

    @biz_retent_totals = @biz_retent_contract.zip(@biz_retent_no_contract).map { |d| d[0]+d[1] }

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
