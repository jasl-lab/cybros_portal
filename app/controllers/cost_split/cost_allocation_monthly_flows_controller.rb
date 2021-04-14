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
    @split_cost_item_details = SplitCost::SplitCostItemDetail.where(month: @beginning_of_month)
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

    split_cost_items = SplitCost::SplitCostItemDetail.where(month: beginning_of_month)
      .order(:to_split_company_code)
      .group(:to_split_company_code)
      .select('to_split_company_code, SUM(IFNULL(group_cost,0)) group_cost, SUM(IFNULL(shanghai_area_cost,0)) shanghai_area_cost, SUM(IFNULL(shanghai_hq_cost,0)) shanghai_hq_cost')

    current_adjusts = SplitCost::CostSplitCompanyMonthlyAdjust
      .where(month: beginning_of_month, group_expense_share_plan_approval_id: gespa.id)

    user_split_cost_details = SplitCost::UserSplitCostDetail.where(month: beginning_of_month)
      .select('to_split_company_code, SUM(IFNULL(group_cost,0)) group_cost, SUM(IFNULL(shanghai_area_cost,0)) shanghai_area_cost, SUM(IFNULL(shanghai_hq_cost,0)) shanghai_hq_cost')
      .group(:to_split_company_code)
      .order(:to_split_company_code)

    split_cost_item_details = SplitCost::SplitCostItemDetail.where(month: beginning_of_month)
      .select('split_cost_item_category, to_split_company_code, SUM(IFNULL(group_cost,0)) group_cost, SUM(IFNULL(shanghai_area_cost,0)) shanghai_area_cost, SUM(IFNULL(shanghai_hq_cost,0)) shanghai_hq_cost')
      .group(:split_cost_item_category, :to_split_company_code)
      .order(:split_cost_item_category, :to_split_company_code)

    approval_contents = split_cost_items.collect do |d|
      ca = current_adjusts.find { |adj| adj.to_split_company_code == d.to_split_company_code }
      uscd = user_split_cost_details.find { |usd| usd.to_split_company_code == d.to_split_company_code }
      scids = split_cost_item_details.find_all { |scd| scd.to_split_company_code == d.to_split_company_code }

      before_adjust_total_cost = d.group_cost.to_i + d.shanghai_area_cost.to_i + d.shanghai_hq_cost.to_i
      user_split_cost_details_wages = uscd.group_cost.to_i + uscd.shanghai_area_cost.to_i + uscd.shanghai_hq_cost.to_i
      split_cost_item_fixed_assets = scids.filter { |u| u.split_cost_item_category == '固定资产' }.sum(&:group_cost) + scids.filter { |u| u.split_cost_item_category == '固定资产' }.sum(&:shanghai_area_cost) + scids.filter { |u| u.split_cost_item_category == '固定资产' }.sum(&:shanghai_hq_cost)
      split_cost_item_intangible_assets = scids.filter { |u| u.split_cost_item_category == '无形资产' }.sum(&:group_cost) + scids.filter { |u| u.split_cost_item_category == '无形资产' }.sum(&:shanghai_area_cost) + scids.filter { |u| u.split_cost_item_category == '无形资产' }.sum(&:shanghai_hq_cost)
      split_cost_item_operational_expenditure_budget = scids.filter { |u| u.split_cost_item_category == '业务性支出预算' }.sum(&:group_cost) + scids.filter { |u| u.split_cost_item_category == '业务性支出预算' }.sum(&:shanghai_area_cost) + scids.filter { |u| u.split_cost_item_category == '业务性支出预算' }.sum(&:shanghai_hq_cost)
      split_cost_item_wages_assets_total = user_split_cost_details_wages.to_i + split_cost_item_fixed_assets.to_i + split_cost_item_intangible_assets.to_i + split_cost_item_operational_expenditure_budget.to_i
      {
        company_code: d.to_split_company_code,
        company_name: Bi::OrgShortName.company_short_names_by_orgcode.fetch(d.to_split_company_code, d.to_split_company_code),
        group_cost: d.group_cost,
        shanghai_area_cost: d.shanghai_area_cost,
        shanghai_hq_cost: d.shanghai_hq_cost,
        group_cost_adjust: ca&.group_cost_adjust,
        shanghai_area_cost_adjust: ca&.shanghai_area_cost_adjust,
        shanghai_hq_cost_adjust: ca&.shanghai_hq_cost_adjust,
        after_adjust_total_cost: before_adjust_total_cost + ca&.group_cost_adjust.to_i + ca&.shanghai_area_cost_adjust.to_i + ca&.shanghai_hq_cost_adjust.to_i,
        user_split_cost_details_wages: user_split_cost_details_wages,
        split_cost_item_fixed_assets: split_cost_item_fixed_assets,
        split_cost_item_intangible_assets: split_cost_item_intangible_assets,
        split_cost_item_operational_expenditure_budget: split_cost_item_operational_expenditure_budget,
        split_cost_item_wages_assets_total: split_cost_item_wages_assets_total,
        split_cost_item_wages_assets_tax: 0.06,
        split_cost_item_wages_assets_total_with_tax: split_cost_item_wages_assets_total*1.06
      }
    end
    Rails.logger.debug "CostAllocationMonthlyFlows approval_contents: #{approval_contents}"

    bizData = {
      sender: 'Cybros',
      approval_id: gespa.id,
      approval_month: gespa.month.to_s(:short_date),
      approval_contents: approval_contents
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
