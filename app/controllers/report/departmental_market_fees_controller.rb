# frozen_string_literal: true

class Report::DepartmentalMarketFeesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"Bi::DepartmentalMarketFees"
    prepare_meta_tags title: t(".title")
    @redirect_url = "view/report?viewlet=FR/Finance/部门市场费主页面.cpt&ref_t=design&op=view&ref_c=16a27647-5aaf-48a6-b1fb-8496756a6a9e"
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "financial_management"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.financial_management.header"),
      link: report_financial_management_path }]
  end
end
