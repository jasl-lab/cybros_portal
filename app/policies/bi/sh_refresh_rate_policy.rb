# frozen_string_literal: true

module Bi
  class ShRefreshRatePolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS } || user.admin?
          scope.all
        else
          scope.where('date >= ?', 1.month.ago)
        end
      end
    end

    def show?
      true
    end
  end
end
