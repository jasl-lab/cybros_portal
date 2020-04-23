# frozen_string_literal: true

class Report::RtGroupHrMonthliesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    prepare_meta_tags title: t(".title")
    @redirect_url = "view/report?viewlet=HR/HR_REPORT_MONTH_1.cpt&ref_t=design&ref_c=864a5e40-658a-4d13-91c4234fac3cfc14"
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    render 'report/human_resources/show'
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "human_resource"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.human_resource.header"),
      link: report_human_resource_path }]
  end
end
