module Bi
  class ContractSignDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
