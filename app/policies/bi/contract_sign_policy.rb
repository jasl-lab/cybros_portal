module Bi
  class ContractSignPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? \
          || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
          || user.roles.pluck(:group_report_viewer).any?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?

      (user.admin? \
      || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
      || user.roles.pluck(:group_report_viewer).any?)
    end
  end
end
