# frozen_string_literal: true

module SplitCost
  class UserSplitClassifySalaryPerMonthPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[财务分析-薪资分摊设置管理员]) }
          scope.all
        elsif user.part_time_split_access_codes.present?
          SplitCost::UserSplitClassifySalaryPerMonths::Scope::LaborCostUser
            .call(current_user: user)
            .data[:user_split_classify_salary_per_months]
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?

      user.admin? \
      || user.roles.pluck(:role_name).any? { |r| r.in?(%w[财务分析-薪资分摊设置管理员]) } \
      || user.part_time_split_access_codes.present?
    end

    def index?
      show?
    end

    def create?
      show?
    end

    def destroy?
      show?
    end
  end
end
