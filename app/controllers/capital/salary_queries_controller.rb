# frozen_string_literal: true

class Capital::SalaryQueriesController < Capital::BaseController
  before_action :authenticate_user!
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"Capital::SalaryQuery"
    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/report?viewlet=CW/CW_HR_SALARY_RP.cpt&ref_t=design&op=view&ref_c=801b8c06-a917-4d7f-9392-f9da3a1157ba'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path }
      ]
    end

    def set_page_layout_data
      @_sidebar_name = 'application'
    end
end
