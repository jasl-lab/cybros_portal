# frozen_string_literal: true

class CostSplit::CostAllocationMonthlyFlowsController < CostSplit::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(SplitCost::UserSplitCostDetail).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @beginning_of_month = Date.parse(@month_name).beginning_of_month

    @split_cost_item_details = SplitCost::SplitCostItemDetail
      .where(month: @beginning_of_month)
      .order(:to_split_company_code)
      .group(:to_split_company_code)
      .select('to_split_company_code, SUM(IFNULL(group_cost,0)) group_cost, SUM(IFNULL(shanghai_area_cost,0)) shanghai_area_cost, SUM(IFNULL(shanghai_hq_cost,0)) shanghai_hq_cost')

    @current_adjusts = SplitCost::CostSplitCompanyMonthlyAdjust.where(month: @beginning_of_month)
    @next_adjusts = SplitCost::CostSplitCompanyMonthlyAdjust.where(month: @beginning_of_month.next_month.beginning_of_month)
  end
end
