module Bi
  class ContractSignPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.admin?
    end
  end
end
