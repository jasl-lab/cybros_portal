# frozen_string_literal: true

class Report::KeyCustomerDetailsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"Bi::KeyCustomerDetail"
    prepare_meta_tags title: t(".title")
    @redirect_url = "view/form?ref_c=22f8bde7-a30e-41e3-975f-01175fe25280&viewlet=FR%252F%25E5%25A4%25A7%25E5%25AE%25A2%25E6%2588%25B7%252F%25E6%259F%25A5%25E8%25AF%25A2%25E4%25B8%25BB%25E9%25A1%25B5%25E9%259D%25A2.frm&ref_t=design"
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    render 'shared/report_show'
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "report"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.key_customer_detail.header"),
      link: report_key_customer_detail_path }]
  end
end
