# frozen_string_literal: true

module Bi
  class CompleteValuePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.admin? || %w[000176].include?(user.clerk_code))
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.admin? || %w[000176].include?(user.clerk_code)
    end
  end
end
