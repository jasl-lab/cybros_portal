module Bi
  class SubCompanyNeedReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_viewer? || user&.report_admin?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      user&.report_viewer? || user&.report_admin?
    end
  end
end
