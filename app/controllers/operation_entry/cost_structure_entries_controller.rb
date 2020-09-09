# frozen_string_literal: true

class OperationEntry::CostStructureEntriesController < OperationEntry::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"OperationEntry::CostStructureEntry"
    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/report?op=write&viewlet=FR/Finance/SubCompanyCostFill.cpt&ref_t=design'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'operation_entry'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation_entry.header'),
        link: report_operation_entry_path }]
    end
end
