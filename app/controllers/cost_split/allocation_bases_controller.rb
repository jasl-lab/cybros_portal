# frozen_string_literal: true

class CostSplit::AllocationBasesController < CostSplit::BaseController
  include AllocationBaseHelper

  def index
    prepare_meta_tags title: t('.title')
    @all_pmonths = policy_scope(SplitCost::CostSplitAllocationBase).all_pmonths
    @p_month = params[:p_month]&.strip || @all_pmonths.first
    @cost_split_allocation_bases = SplitCost::CostSplitAllocationBase.where(pmonth: @p_month)
  end

  def new
    @base_name = params[:base_name]
    @company_code = params[:company_code]
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.new(base_name: @base_name, company_code: @company_code, pmonth: '2020-11')

    @csab_histories = SplitCost::CostSplitAllocationBase.where(base_name: @base_name, company_code: @company_code, pmonth: '2020-11')
  end

  def create
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.create(
      base_name: cost_split_allocation_base_params[:base_name],
      company_code: cost_split_allocation_base_params[:company_code],
      head_count: cost_split_allocation_base_params[:head_count])
  end

  def edit
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.find(params[:id])

    @csab_histories = SplitCost::CostSplitAllocationBase.where(base_name: @cost_split_allocation_base.base_name, company_code: @cost_split_allocation_base.company_code)
  end

  def update
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.find(params[:id])
    @cost_split_allocation_base.update(cost_split_allocation_base_params)
  end

  private

    def cost_split_allocation_base_params
      params.fetch(:split_cost_cost_split_allocation_base, {})
        .permit(:base_name, :company_code, :head_count)
    end
end
