module Bi
  class ContractSignPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_view_all).any? || user.admin?
    end
  end
end
