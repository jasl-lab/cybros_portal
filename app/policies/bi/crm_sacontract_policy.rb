module Bi
  class CrmSacontractPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.admin? || user.chinese_name.in?(%w[王旭冉 王俐雯])
          scope.all
        else
          scope.none
        end
      end

      def overview_resolve
        scope.all
      end
    end
  end
end
