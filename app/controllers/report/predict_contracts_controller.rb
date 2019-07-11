class Report::PredictContractsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    last_available_date = Bi::PredictContract.last_avaiable_date

    data = policy_scope(Bi::PredictContract).where(date: last_available_date)
      .select('businessltdcode, SUM(contractconvert) contractconvert, SUM(count) count')
      .group(:businessltdcode)

    all_business_ltd_codes = data.collect(&:businessltdcode)
    @company_short_names = all_business_ltd_codes.collect do |c|
      long_name = Bi::PkCodeName.company_long_names.fetch(c, c)
      Bi::StaffCount.company_short_names.fetch(long_name, long_name)
    end

    @contract_convert = data.collect do |d|
      (d.contractconvert / 10000.to_f).round(2)
    end
    @contract_count = data.collect(&:count)
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.predict_contract"),
      link: report_predict_contract_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
