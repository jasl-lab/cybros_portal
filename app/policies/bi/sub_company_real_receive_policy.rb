module Bi
  class SubCompanyRealReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_maintainer?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      user&.report_maintainer?
    end
  end
end
