module Bi
  class WorkHoursCountDetailDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? &&
          (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?) &&
          user.departments.pluck(:company_name).uniq == ["上海天华建筑设计有限公司"]
          scope.all
        else
          scope.where(orgname: user.departments.pluck(:company_name))
        end
      end
    end
  end
end
