# frozen_string_literal: true

module Bi
  class CrmClientReceivePolicy < BasePolicy
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

    def show?
      return false unless user.present?

      user.admin?
    end
  end
end
