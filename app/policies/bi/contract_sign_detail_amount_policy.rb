module Bi
  class ContractSignDetailAmountPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?)
          scope.all
        else
          scope.where(orgname: user.departments.pluck(:company_name))
        end
      end
    end

    def drill_down_amount?
      show?
    end
  end
end
