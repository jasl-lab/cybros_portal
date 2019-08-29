# frozen_string_literal: true

class Report::ContractSignDetailsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    respond_to do |format|
      format.html
      format.json { render json: ContractSignDetailDatatable.new(params) }
    end
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.contract_sign_detail"),
        link: report_contract_sign_detail_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
