module Bi
  class ContractSignPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def show?
      user&.report_maintainer?
    end
  end
end
