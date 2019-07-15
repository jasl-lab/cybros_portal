module Bi
  class ContractHoldPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_maintainer?
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
