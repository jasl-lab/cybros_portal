module Bi
  class ContractSignDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_maintainer?
          scope.all
        else
          scope.where(performancecompanyname: user.departments.pluck(:company_name))
        end
      end
    end

    def drill_down?
      show?
    end
  end
end
