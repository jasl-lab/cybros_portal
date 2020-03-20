# frozen_string_literal: true

class Report::SubsidiariesOperatingComparisonsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.subsidiaries_operating_comparison'),
        link: report_subsidiaries_operating_comparison_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
