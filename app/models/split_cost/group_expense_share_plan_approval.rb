# frozen_string_literal: true

module SplitCost
  class GroupExpenseSharePlanApproval < ApplicationRecord
    belongs_to :user
    has_many: :cost_split_company_monthly_adjusts
  end
end
