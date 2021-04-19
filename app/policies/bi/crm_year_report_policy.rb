# frozen_string_literal: true

module Bi
  class CrmYearReportPolicy < BasePolicy
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
      user.admin?
    end
  end
end
