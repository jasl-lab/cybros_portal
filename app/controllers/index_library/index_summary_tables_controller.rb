# frozen_string_literal: true

class IndexLibrary::IndexSummaryTablesController < IndexLibrary::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"IndexLibrary::IndexSummaryTables"
    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/report?op=write&viewlet=BI/DataLibrary/DATA_TABLE.cpt&ref_t=design'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'index_library'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.index_library.header'),
        link: index_library_root_path }]
    end
end
