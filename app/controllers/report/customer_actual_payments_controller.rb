# frozen_string_literal: true

class Report::CustomerActualPaymentsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(Bi::CrmClientSum).all_month_names
    @month_name = params[:month_name] || @all_month_names.first

    @data = policy_scope(Bi::CrmYearReport)
      .select('year, sum(top20) top20, sum(top20to50) top20to50, sum(gt50) gt50, sum(others) others')
      .group(:year)
      .order(:year)

    @years = @data.collect(&:year)
    @top20s = @data.collect { |d| (d.top20 / 100_0000.0).round(1) }
    @top20to50s = @data.collect { |d| (d.top20to50 / 100_0000.0).round(1) }
    @gt50s = @data.collect { |d| (d.gt50 / 100_0000.0).round(1) }
    @others = @data.collect { |d| (d.others / 100_0000.0).round(1) }
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.customer_actual_payment'),
        link: report_customer_actual_payments_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
