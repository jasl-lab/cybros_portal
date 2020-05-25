# frozen_string_literal: true

class Report::ContractInformationFormsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    authorize :"Bi::ContractInformationForm"
    prepare_meta_tags title: t(".title")
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
