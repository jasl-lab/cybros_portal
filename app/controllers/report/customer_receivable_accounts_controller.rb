# frozen_string_literal: true

class Report::CustomerReceivableAccountsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.customer_receivable_account'),
        link: report_customer_receivable_accounts_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
