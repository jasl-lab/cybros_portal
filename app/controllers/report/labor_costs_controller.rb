# frozen_string_literal: true

class Report::LaborCostsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    authorize SplitCost::UserSplitClassifySalaryPerMonth
    @all_month_names = policy_scope(SplitCost::UserSplitClassifySalaryPerMonth).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.second
    @beginning_of_month = Date.parse(@month_name).beginning_of_month
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'application'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.financial_management.header'),
        link: report_financial_management_path }]
    end
end
