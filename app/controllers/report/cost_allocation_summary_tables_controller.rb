# frozen_string_literal: true

class Report::CostAllocationSummaryTablesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }
  before_action :prepare_encrypt_uid

  def show
    authorize :"SplitCost::CostAllocationSummaryTable"
    prepare_meta_tags title: t('.title')
    @redirect_url = 'view/report?viewlet=SPLIT/expense_split_rep.cpt&ref_t=design&op=write&ref_c=a10ffa2e-f284-4be4-aa9a-8e28b001d0d7'
    @hide_app_footer = true
    @hide_main_header_wrapper = true
    @hide_scroll = true
    render 'shared/report_show'
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'cost_split'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
        { text: t('layouts.sidebar.cost_split.header'),
          link: cost_split_root_path },
        { text: t('layouts.sidebar.cost_split.human_resource'),
          link: cost_split_human_resources_path }]
    end
end
