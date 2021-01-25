# frozen_string_literal: true

module SplitCost
  class UserSalaryClassification < ApplicationRecord
    has_many :user_split_classify_salaries
  end
end
