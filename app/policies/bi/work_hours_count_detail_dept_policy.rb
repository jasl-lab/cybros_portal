module Bi
  class WorkHoursCountDetailDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
          scope.where(orgname: user.departments.pluck(:company_name))
        else
          scope.none
        end
      end
    end
  end
end
