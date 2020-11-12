# frozen_string_literal: true

class CostSplit::SplitCostItemsController < CostSplit::BaseController
  before_action :set_split_cost_item, except: %i[create index]

  def index
    prepare_meta_tags title: t('.title')
    @split_cost_items = SplitCost::SplitCostItem.all.page(params[:page]).per(params[:per_page])
    @new_split_cost_item = SplitCost::SplitCostItem.new
  end

  def create
    split_cost_item = SplitCost::SplitCostItem.new(split_cost_item_params)
    split_cost_item.version ||= 0
    split_cost_item.start_date ||= Date.today
    split_cost_item.save
    redirect_to cost_split_split_cost_items_path, notice: t('.success')
  end

  def destroy
    @split_cost_item.destroy
    redirect_to cost_split_split_cost_items_path, notice: t('.success')
  end

  def update
    @split_cost_item.update(split_cost_item_params)
    redirect_to cost_split_split_cost_items_path, notice: t('.success')
  end

  def confirm
    @split_cost_item.update(confirmed: true)
    redirect_to cost_split_split_cost_items_path, notice: t('.success')
  end

  def version_up
    @split_cost_item.update(end_date: Date.today)
    redirect_to cost_split_split_cost_items_path, notice: t('.success')
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

  private

    def set_split_cost_item
      @split_cost_item = SplitCost::SplitCostItem.find(params[:id])
    end

    def split_cost_item_params
      params.fetch(:split_cost_split_cost_item, {})
        .permit(:split_cost_item_no, :split_cost_item_name, :split_cost_item_category,
          :group_rate, :shanghai_area, :shanghai_hq,
          :group_rate_base, :shanghai_area_base, :shanghai_hq_base,
          split_cost_item_group_rate_companies_codes: [],
          split_cost_item_shanghai_area_rate_companies_codes: [],
          split_cost_item_shanghai_hq_rate_companies_codes: [])
    end
end
