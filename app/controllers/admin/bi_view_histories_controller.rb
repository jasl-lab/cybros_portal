# frozen_string_literal: true

class Report::BiViewHistoriesController < Admin::ApplicationController

  def show

    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/form?viewlet=BI/VIEW_HISTORIES.frm&ref_t=design&ref_c=64b9edda-f7bb-4838-95bc-c69304833370'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  # protected

  #   def set_page_layout_data
  #     @_sidebar_name = 'human_resource'
  #   end

  #   def set_breadcrumbs
  #     @_breadcrumbs = [
  #     { text: t('layouts.sidebar.application.header'),
  #       link: root_path },
  #     { text: t('layouts.sidebar.human_resource.header'),
  #       link: report_human_resource_path }]
  #   end
end
