module Bi
  class ContractSignPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if (user.admin? || user.roles.pluck(:group_report_viewer).any?)
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      (user.admin? || user.roles.pluck(:group_report_viewer).any?)
    end
  end
end
