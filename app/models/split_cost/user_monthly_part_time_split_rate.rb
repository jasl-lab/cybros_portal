# frozen_string_literal: true

module SplitCost
  class UserMonthlyPartTimeSplitRate < ApplicationRecord
    belongs_to :user
    belongs_to :position
    belongs_to :user_job_type, class_name: 'SplitCost::UserJobType', optional: true
    belongs_to :user_salary_classification

    def self.all_month_names
      SplitCost::UserMonthlyPartTimeSplitRate.order(month: :desc).select(:month).distinct.pluck(:month).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.available_company_name_org_codes(target_month)
      where(month: target_month).joins(position: :department)
        .pluck(:company_code).uniq
        .collect { |c| [Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c), c] }
    end
  end
end
