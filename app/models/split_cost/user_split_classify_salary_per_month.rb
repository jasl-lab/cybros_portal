# frozen_string_literal: true

module SplitCost
  class UserSplitClassifySalaryPerMonth < ApplicationRecord
    belongs_to :user
    belongs_to :position
    belongs_to :user_job_type
    belongs_to :user_cost_type
  end
end
