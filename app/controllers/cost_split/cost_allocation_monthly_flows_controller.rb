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

    if gespa.begin_task_id.present? || gespa.backend_in_processing
      redirect_to cost_split_cost_allocation_monthly_flow_path(id: gespa.id), notice: t('.repeated_approve_request')
      return
    end

    bizData = {
      sender: 'Cybros'
    }

    gespa.update_columns(backend_in_processing: true)
    response = HTTP.post("#{Rails.application.credentials[Rails.env.to_sym][:bpm_core_process_handler]}/Submit/GroupExpenseSharePlanApproval/Begin/1",
      json: { userCode: current_user.clerk_code, comments: '', taskId: '', bizData: bizData.to_json })
    Rails.logger.debug "CostAllocationMonthlyFlows response: #{response}"
    result = JSON.parse(response.body.to_s)
    gespa.update_columns(backend_in_processing: false)

    if result['isSuccess'] == '1'
      gespa.update_columns(begin_task_id: result['BeginTaskId'])
      redirect_to cost_split_cost_allocation_monthly_flow_path(id: gespa.id), notice: t('.approve_success')
    else
      gespa.update_columns(bpm_message: result['message'])
      redirect_to cost_split_cost_allocation_monthly_flow_path(id: gespa.id), notice: t('.approve_failed', message: result['message'])
    end
  end
end
