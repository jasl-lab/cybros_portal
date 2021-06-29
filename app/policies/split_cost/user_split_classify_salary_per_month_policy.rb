# frozen_string_literal: true

module SplitCost
  class UserSplitClassifySalaryPerMonthPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[财务分析-薪资分摊设置管理员]) }
          scope.all
        elsif user.part_time_split_access_codes.present?
          can_access_user_ids = Users::AccessCode::LaborCostUser
            .call(current_user: user)
            .data[:access_users].pluck(:id)
          scope.where(user_id: can_access_user_ids)
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
