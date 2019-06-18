class Report::SubsidiaryReceivesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  after_action :verify_authorized

  def show
    authorize Bi::SubCompanyNeedReceive
    @all_month_names = Bi::SubCompanyNeedReceive.all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_month = Date.parse(@month_name).end_of_month

    current_user_companies = current_user.departments.collect(&:company_name)
    @data = if current_user_companies.include?('上海天华建筑设计有限公司')
      Bi::SubCompanyNeedReceive.all
    else
      Bi::SubCompanyNeedReceive.where(businessltdname: current_user_companies)
    end.where('date <= ?', @end_of_month)
      .where.not(businessltdname: '上海天华建筑设计有限公司')
      .select('businessltdname, SUM(account_receive) account_receive')
      .group(:businessltdname)
    @all_company_names = @data.collect(&:businessltdname)
    @all_company_short_names = @all_company_names.collect { |c| Bi::StaffCount.company_short_names.fetch(c, c) }
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("report.subsidiary_receives.show.title"),
      link: report_subsidiary_receive_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
