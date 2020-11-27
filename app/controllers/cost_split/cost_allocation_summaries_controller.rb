# frozen_string_literal: true

class CostSplit::CostAllocationSummariesController < CostSplit::BaseController
  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(SplitCost::UserSplitCostDetail).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
  end
end
