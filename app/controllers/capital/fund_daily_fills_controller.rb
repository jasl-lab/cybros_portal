# frozen_string_literal: true

class Capital::FundDailyFillsController < Capital::BaseController
  before_action :authenticate_user!
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"Capital::FundDailyFill"
    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/report?op=write&viewlet=FR/Finance/CWDailyFillTable.cpt&ref_t=design'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.capital_report.header'),
        link: report_capital_report_path }]
    end
end
