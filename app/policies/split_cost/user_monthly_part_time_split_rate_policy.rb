# frozen_string_literal: true

module SplitCost
  class UserMonthlyPartTimeSplitRatePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[财务分析-薪资分摊设置管理员]) }
          scope.all
        elsif user.part_time_split_access_codes.present?
          scope.where(position: { departments: { company_code: user.part_time_split_access_codes.pluck(:org_code) } })
        else
          scope.none
        end.joins(position: :department)
      end
    end

    def show?
      return false unless user.present?

      user.admin? \
      || user.part_time_split_access_codes.present? \
      || user.roles.pluck(:role_name).any? { |r| r.in?(%w[财务分析-薪资分摊设置管理员]) }
    end
  end
end
