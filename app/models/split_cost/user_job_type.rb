# frozen_string_literal: true

module SplitCost
  class UserJobType < ApplicationRecord
    has_many :user_split_classify_salaries
  end
end
