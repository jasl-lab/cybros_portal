# frozen_string_literal: true

class Report::CimToolsController < Report::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.report.header"),
        link: report_root_path },
      { text: t("layouts.sidebar.report.cim_tools"),
        link: report_cim_tools_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "report"
    end
end
