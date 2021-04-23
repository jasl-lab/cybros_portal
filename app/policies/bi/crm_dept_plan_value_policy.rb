# frozen_string_literal: true

module Bi
  class CrmDeptPlanValuePolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin?
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
