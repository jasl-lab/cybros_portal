# frozen_string_literal: true

module SplitCost
  class CostSplitCompanyMonthlyAdjust < ApplicationRecord
    belongs_to :group_expense_share_plan_approval, optional: true
  end
end
