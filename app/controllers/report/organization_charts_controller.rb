# frozen_string_literal: true

class Report::OrganizationChartsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"Bi::OrganizationChart"
    prepare_meta_tags title: t(".title")
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "application"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.organization_chart.header"),
      link: report_organization_chart_path }]
  end
end
