module Bi
  class WorkHoursCountDetailStaffPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
          scope.where(businessltdname: user.departments.pluck(:company_name))
        else
          scope.none
        end
      end
    end

    def show?
      true
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
