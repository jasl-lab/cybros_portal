# frozen_string_literal: true

module Bi
  class WorkHoursDayCountDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.roles.pluck(:report_view_all).any? || user.admin? \
          || user.operation_access_codes.any? { |c| c[0] <= User::ALL_OF_ALL }
          scope.all
        elsif user.roles.pluck(:report_viewer).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS } \
          || user.roles.pluck(:role_name).any? { |r| r.in?(%w[子公司工时查看]) }
          can_access_org_codes = user.can_access_org_codes.append(user.user_company_orgcode)
          scope.where(orgcode: can_access_org_codes)
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?

      user.roles.pluck(:report_viewer).any? \
      || user.roles.pluck(:report_view_all).any? \
      || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS } \
      || user.roles.pluck(:role_name).any? { |r| r.in?(%w[子公司工时查看]) } \
      || user.admin?
    end

    def export?
      show?
    end

    def day_rate_drill_down?
      show?
    end

    def planning_day_rate_drill_down?
      show?
    end

    def building_day_rate_drill_down?
      show?
    end
  end
end
