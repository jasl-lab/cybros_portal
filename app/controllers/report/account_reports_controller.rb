# frozen_string_literal: true

class Report::AccountReportsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t(".title")
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "account_report"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.account_report.header"),
      link: report_account_report_path }]
  end
end
