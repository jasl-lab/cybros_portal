# frozen_string_literal: true

class CostSplit::CostAllocationMonthlyFlowsController < CostSplit::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    all_month_names = policy_scope(SplitCost::UserSplitCostDetail).all_month_names
    month_name = params[:month_name]&.strip || all_month_names.first

    redirect_to cost_split_cost_allocation_monthly_flow_path(id: month_name)
  end

  def show
    gespa = SplitCost::GroupExpenseSharePlanApproval.find_by id: params[:id]
    @month_name = gespa&.month || params[:id]
    @all_month_names = policy_scope(SplitCost::UserSplitCostDetail).all_month_names
    @beginning_of_month = @month_name.is_a?(Date) ? @month_name : Date.parse(@month_name).beginning_of_month
    @split_cost_item_details = SplitCost::SplitCostItemDetail
      .where(month: @beginning_of_month)
      .order(:to_split_company_code)
      .group(:to_split_company_code)
      .select('to_split_company_code, SUM(IFNULL(group_cost,0)) group_cost, SUM(IFNULL(shanghai_area_cost,0)) shanghai_area_cost, SUM(IFNULL(shanghai_hq_cost,0)) shanghai_hq_cost')

    @current_adjusts = SplitCost::CostSplitCompanyMonthlyAdjust.where(month: @beginning_of_month)
    @next_adjusts = SplitCost::CostSplitCompanyMonthlyAdjust.where(month: @beginning_of_month.next_month.beginning_of_month)
  end

  def start_approve
    month_name = params[:id]
    beginning_of_month = Date.parse(month_name).beginning_of_month

    gespa = SplitCost::GroupExpenseSharePlanApproval.find_or_initialize_by(month: beginning_of_month)
    gespa.user_id = current_user.id
    gespa.save
    SplitCost::CostSplitCompanyMonthlyAdjust.where(month: gespa.month).each do |cscma|
      cscma.update(group_expense_share_plan_approval_id: gespa.id)
    end

    redirect_to cost_split_cost_allocation_monthly_flow_path(id: gespa.id), notice: t('.approve_success')
  end
end
