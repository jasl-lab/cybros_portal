# frozen_string_literal: true

class Report::SubsidiaryNeedReceiveUnsignDetailsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::SubCompanyNeedReceiveUnsignDetail
    @can_hide_item = pundit_user.report_admin?
    @show_hide_item = params[:show_hide_item] == "true" && @can_hide_item

    respond_to do |format|
      format.html
      format.json do
        subsidiary_need_receive_unsign_details = policy_scope(Bi::SubCompanyNeedReceiveUnsignDetail)
        render json: SubsidiaryNeedReceiveUnsignDetailDatatable.new(params,
          subsidiary_need_receive_unsign_details: subsidiary_need_receive_unsign_details,
          show_hide: @show_hide_item,
          view_context: view_context)
      end
    end
  end

  def hide
    authorize Bi::SubCompanyNeedReceiveUnsignDetail
    project_item_code = params[:project_item_code]
    Bi::SubCompanyNeedReceiveUnsignDetail.where(projectitemcode: project_item_code).update_all(need_hide: true)
    redirect_to report_subsidiary_need_receive_unsign_detail_path
  end

  def un_hide
    authorize Bi::SubCompanyNeedReceiveUnsignDetail
    project_item_code = params[:project_item_code]
    Bi::SubCompanyNeedReceiveUnsignDetail.where(projectitemcode: project_item_code).update_all(need_hide: nil)
    redirect_to report_subsidiary_need_receive_unsign_detail_path(show_hide_item: true)
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.subsidiary_need_receive_unsign_detail"),
        link: report_subsidiary_need_receive_unsign_detail_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
