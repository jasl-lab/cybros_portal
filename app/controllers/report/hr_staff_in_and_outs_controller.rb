# frozen_string_literal: true

class Report::HrStaffInAndOutsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"Bi::HrStaffInAndOut"
    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/report?op=write&viewlet=HR/SY_staff_in_out.frm&ref_t=design'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'human_resource'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.human_resource.header'),
        link: report_human_resource_path }]
    end
end
