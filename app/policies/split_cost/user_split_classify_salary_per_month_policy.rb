# frozen_string_literal: true

module SplitCost
  class UserSplitClassifySalaryPerMonthPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[财务分析-薪资分摊设置管理员]) }
          scope.all
        else
          scope.none
        end
      end
    end

    def index?
      return false unless user.present?

      user.admin? \
      || user.roles.pluck(:role_name).any? { |r| r.in?(%w[财务分析-薪资分摊设置管理员]) }
    end
  end
end
