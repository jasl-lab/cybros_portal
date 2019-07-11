module Bi
  class PredictContractPolicy < BasePolicy
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
