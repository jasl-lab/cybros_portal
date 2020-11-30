# frozen_string_literal: true

class Report::GroupPredictContractsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(Bi::TrackContract, :group_resolve).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    if @month_name.blank?
      flash[:alert] = I18n.t('not_data_authorized')
      raise Pundit::NotAuthorizedError
    end
    end_of_month = Date.parse(@month_name).end_of_month
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @last_available_date = policy_scope(Bi::TrackContract, :group_resolve).where(date: beginning_of_month..end_of_month).order(date: :desc).first.date
    @view_orgcode_sum = params[:view_orgcode_sum] == 'true'

  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_predict_contract'),
        link: report_group_predict_contract_path }]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
