# frozen_string_literal: true

module SplitCost
  class UserSplitCostDetail < ApplicationRecord
    belongs_to :user
  end
end
