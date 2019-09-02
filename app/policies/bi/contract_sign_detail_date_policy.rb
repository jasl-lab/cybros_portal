module Bi
  class ContractSignDetailDatePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_viewer? || user&.report_admin?
          scope.all
        else
          scope.where(orgname: user.departments.pluck(:company_name))
        end
      end
    end

    def drill_down_date?
      show?
    end
  end
end
