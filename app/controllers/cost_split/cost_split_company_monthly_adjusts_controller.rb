# frozen_string_literal: true

class CostSplit::CostSplitCompanyMonthlyAdjustsController < CostSplit::BaseController
  def create
  end

  private

    def split_cost_cost_split_company_monthly_adjust_params
      params.fetch(:split_cost_cost_split_company_monthly_adjust, {})
        .permit(:month, :group_cost_adjust, :shanghai_area_cost_adjust, :shanghai_hq_cost_adjust)
    end
end
