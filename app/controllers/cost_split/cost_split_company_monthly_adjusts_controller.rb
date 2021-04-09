# frozen_string_literal: true

class CostSplit::CostSplitCompanyMonthlyAdjustsController < CostSplit::BaseController
  def create
    SplitCost::CostSplitCompanyMonthlyAdjust
      .create(split_cost_cost_split_company_monthly_adjust_params.merge(user_id: current_user.id))
  end

  private

    def split_cost_cost_split_company_monthly_adjust_params
      params.fetch(:split_cost_cost_split_company_monthly_adjust, {})
        .permit(:to_split_company_code, :month, :group_cost_adjust, :shanghai_area_cost_adjust, :shanghai_hq_cost_adjust)
    end
end
