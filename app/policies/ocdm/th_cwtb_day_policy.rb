# frozen_string_literal: true

module Ocdm
  class ThCwtbDayPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务管理员]) }
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?

      user.admin? || \
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务管理员]) }
    end
  end
end
