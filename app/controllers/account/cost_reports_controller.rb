# frozen_string_literal: true

class Account::CostReportsController < Account::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"Account::CostReportShow"
    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/report?op=write&viewlet=CW/COST_REPORT.cpt&ref_t=design'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'application'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.account_split_setting.header'),
        link: report_account_split_setting_path }]
    end
end
