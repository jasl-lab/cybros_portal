module Bi
  class WorkHoursDayCountOrgPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
          scope.where(orgcode: user.can_access_org_codes)
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? \
      || user.roles.pluck(:report_view_all).any? \
      || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
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
