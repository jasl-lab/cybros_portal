# frozen_string_literal: true

class Report::SubsidiaryNeedReceiveSignDetailsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::SubCompanyNeedReceiveSignDetail
    @all_month_names = policy_scope(Bi::SubCompanyNeedReceiveSignDetail).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @end_of_date = policy_scope(Bi::SubCompanyNeedReceiveSignDetail)
      .where(date: Date.parse(@month_name).beginning_of_month..Date.parse(@month_name).end_of_month).order(date: :desc).pluck(:date).first
    @sign_receive_great_than = params[:sign_receive_great_than] || 100_0000
    @can_hide_item = pundit_user.roles.pluck(:report_reviewer).any?
    @show_hide_item = params[:show_hide_item] == "true" && @can_hide_item

    respond_to do |format|
      format.html
      format.json do
        subsidiary_need_receive_sign_details = policy_scope(Bi::SubCompanyNeedReceiveSignDetail)
        render json: SubsidiaryNeedReceiveSignDetailDatatable.new(params,
          subsidiary_need_receive_sign_details: subsidiary_need_receive_sign_details,
          end_of_date: @end_of_date,
          sign_receive_great_than: @sign_receive_great_than.to_i,
          show_hide: @show_hide_item,
          view_context: view_context)
      end
    end
  end

  def hide
    authorize Bi::SubCompanyNeedReceiveSignDetail
    sales_contract_code = params[:sales_contract_code]
    Bi::SubCompanyNeedReceiveSignDetail.where(salescontractcode: sales_contract_code).update_all(need_hide: true)
    redirect_to report_subsidiary_need_receive_sign_detail_path
  end

  def un_hide
    authorize Bi::SubCompanyNeedReceiveSignDetail
    sales_contract_code = params[:sales_contract_code]
    Bi::SubCompanyNeedReceiveSignDetail.where(salescontractcode: sales_contract_code).update_all(need_hide: nil)
    redirect_to report_subsidiary_need_receive_sign_detail_path(show_hide_item: true)
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.subsidiary_need_receive_sign_detail"),
        link: report_subsidiary_need_receive_sign_detail_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
