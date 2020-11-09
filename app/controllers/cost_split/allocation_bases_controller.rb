# frozen_string_literal: true

class CostSplit::AllocationBasesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
    @cost_split_allocation_bases = SplitCost::CostSplitAllocationBase.all
  end

  def new
    @base_name = params[:base_name]
    @company_code = params[:company_code]
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.new(base_name: @base_name, company_code: @company_code)
  end

  def create
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.create(cost_split_allocation_base_params)
  end

  def edit
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.find(params[:id])
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
