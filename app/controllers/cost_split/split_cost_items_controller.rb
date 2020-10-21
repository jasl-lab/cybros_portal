# frozen_string_literal: true

class CostSplit::SplitCostItemsController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
  end

  protected

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.cost_split.header'),
        link: cost_split_root_path },
      { text: t('layouts.sidebar.cost_split.split_cost_items'),
        link: cost_split_split_cost_items_path }]
    end
end
