# frozen_string_literal: true

class CostSplit::AllocationBasesController < CostSplit::BaseController
  include AllocationBaseHelper

  def index
    prepare_meta_tags title: t('.title')
    @cost_split_allocation_bases = SplitCost::CostSplitAllocationBase
      .where.not(start_date: nil)
      .where(end_date: nil)
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
    case params[:form_action]
    when 'save'
      @cost_split_allocation_base.update(cost_split_allocation_base_params)
    when 'confirm'
      @cost_split_allocation_base.update(cost_split_allocation_base_params)
      @cost_split_allocation_base.update_columns(start_date: Date.today)
    when 'version_up'
      @cost_split_allocation_base.update(end_date: Date.today)
    end
  end

  def submit
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.find(params[:id])
    @cost_split_allocation_base.update(version:
      SplitCost::CostSplitAllocationBase.where(base_name: @cost_split_allocation_base.base_name, company_code: @cost_split_allocation_base.company_code).count)
    render :update
  end

  def reject
    @cost_split_allocation_base = SplitCost::CostSplitAllocationBase.find(params[:id])
    @cost_split_allocation_base.update(version: nil)
    render :update
  end

  private
    def cost_split_allocation_base_params
      params.fetch(:split_cost_cost_split_allocation_base, {})
        .permit(:base_name, :company_code, :head_count)
    end
end
