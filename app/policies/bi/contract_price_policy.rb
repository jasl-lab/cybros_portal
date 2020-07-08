module Bi
  class ContractPricePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if (user.admin? || user.chinese_name.in?(%w(王旭冉 王俐雯))
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
