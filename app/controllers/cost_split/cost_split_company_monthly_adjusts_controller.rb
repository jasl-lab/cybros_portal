# frozen_string_literal: true

class CostSplit::CostSplitCompanyMonthlyAdjustsController < CostSplit::BaseController
  def create
    to_split_company_code = split_cost_cost_split_company_monthly_adjust_params.delete(:to_split_company_code)
    month = split_cost_cost_split_company_monthly_adjust_params.delete(:month)
    adj = SplitCost::CostSplitCompanyMonthlyAdjust.find_or_create_by(to_split_company_code: to_split_company_code, month: month)
    adj.update(split_cost_cost_split_company_monthly_adjust_params.merge(user_id: current_user.id))
  end

  private

    def split_cost_cost_split_company_monthly_adjust_params
      params.fetch(:split_cost_cost_split_company_monthly_adjust, {})
        .permit(:to_split_company_code, :month, :group_cost_adjust, :shanghai_area_cost_adjust, :shanghai_hq_cost_adjust)
    end
end
