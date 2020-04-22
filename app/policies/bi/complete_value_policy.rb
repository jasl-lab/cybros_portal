# frozen_string_literal: true

module Bi
  class CompleteValuePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && user.admin?
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
