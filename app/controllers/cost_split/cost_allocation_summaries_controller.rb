# frozen_string_literal: true

class CostSplit::CostAllocationSummariesController < CostSplit::BaseController
  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(SplitCost::UserSplitCostDetail).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    xy_axis_data = SplitCost::UserSplitCostDetail.where(month: beginning_of_month).distinct.select(:v_wata_dept_code, :to_split_company_code)
    all_dept_codes = xy_axis_data.collect(&:v_wata_dept_code).uniq
    to_split_company_codes = xy_axis_data.collect(&:to_split_company_code).uniq

    @ordered_depts = Bi::OrgReportDeptOrder.where(编号: all_dept_codes).order(:显示顺序)
      .select(:编号, :部门).reduce({}) do |h, s|
        h[s.部门] = s.编号
        h
      end
    @ordered_companies = Bi::OrgOrder.where(org_code: to_split_company_codes).order(:org_order)
      .select(:org_code, :org_shortname).reduce({}) do |h, s|
        h[s.org_shortname] = s.org_code
        h
      end

    @user_split_cost_details = SplitCost::UserSplitCostDetail.where(month: beginning_of_month)
      .select('v_wata_dept_code, to_split_company_code, SUM(IFNULL(group_cost,0)) group_cost, SUM(IFNULL(shanghai_area_cost,0)) shanghai_area_cost, SUM(IFNULL(shanghai_hq_cost,0)) shanghai_hq_cost')
      .group(:v_wata_dept_code, :to_split_company_code)
      .order(:v_wata_dept_code, :to_split_company_code)

    @split_cost_items = SplitCost::SplitCostItem.where(month: beginning_of_month)
      .where('split_cost_item_category, to_split_company_code, SUM(IFNULL(group_cost,0)) group_cost, SUM(IFNULL(shanghai_area_cost,0)) shanghai_area_cost, SUM(IFNULL(shanghai_hq_cost,0)) shanghai_hq_cost')
      .group(:split_cost_item_category, :to_split_company_code)
      .order(:split_cost_item_category, :to_split_company_code)
  end

  def drill_down
    dept_code = params[:dept_code].strip
    to_split_company_code = params[:company_code].strip
    month_name = params[:month_name].strip
    beginning_of_month = Date.parse(month_name).beginning_of_month
    @user_split_cost_details = SplitCost::UserSplitCostDetail.where(v_wata_dept_code: dept_code, to_split_company_code: to_split_company_code, month: beginning_of_month)
  end
end
