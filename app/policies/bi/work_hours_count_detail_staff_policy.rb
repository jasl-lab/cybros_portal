module Bi
  class WorkHoursCountDetailStaffPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?)
          scope.all
        else
          scope.where(businessltdname: user.departments.pluck(:company_name))
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
