module Bi
  class SubCompanyRealReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def show?
      true
    end
  end
end
