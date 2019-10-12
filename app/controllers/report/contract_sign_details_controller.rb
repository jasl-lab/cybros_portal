# frozen_string_literal: true

class Report::ContractSignDetailsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::ContractSignDetailDate
    @all_month_names = policy_scope(Bi::ContractSignDetailDate).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    @beginning_of_month = Date.parse(@month_name).beginning_of_month
    @end_of_month = Date.parse(@month_name).end_of_month
    last_available_date = policy_scope(Bi::ContractSignDetailDate).last_available_date(@end_of_month)
    all_org_long_names = policy_scope(Bi::ContractSignDetailDate).all_org_long_names(last_available_date)
    all_org_short_names = all_org_long_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @all_org_names = all_org_short_names.zip(all_org_long_names)
    @org_name = params[:org_name]&.strip
    @date_1_great_than = params[:date_1_great_than] || 100
    @days_to_min_timecard_fill_great_than = params[:days_to_min_timecard_fill_great_than] || 100
    @can_hide_item = pundit_user.roles.pluck(:report_reviewer).any?
    @show_hide_item = params[:show_hide_item] == "true" && @can_hide_item

    respond_to do |format|
      format.html
      format.json do
        contract_sign_detail_dates = policy_scope(Bi::ContractSignDetailDate)
        render json: ContractSignDetailDatatable.new(params,
          contract_sign_detail_dates: contract_sign_detail_dates,
          org_name: @org_name,
          beginning_of_month: @beginning_of_month,
          end_of_month: @end_of_month,
          last_available_date: last_available_date,
          date_1_great_than: @date_1_great_than.to_i,
          show_hide: @show_hide_item,
          view_context: view_context)
      end
    end
  end

  def hide
    authorize Bi::ContractSignDetailDate
    contract_code = params[:contract_code]
    Bi::ContractSignDetailDate.where(salescontractcode: contract_code).update_all(need_hide: true)
    redirect_to report_contract_sign_detail_path
  end

  def un_hide
    authorize Bi::ContractSignDetailDate
    contract_code = params[:contract_code]
    Bi::ContractSignDetailDate.where(salescontractcode: contract_code).update_all(need_hide: nil)
    redirect_to report_contract_sign_detail_path(show_hide_item: true)
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
