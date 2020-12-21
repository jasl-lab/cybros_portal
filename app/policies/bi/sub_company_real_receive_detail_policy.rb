# frozen_string_literal: true

module Bi
  class SubCompanyRealReceiveDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.admin? \
          || user.operation_access_codes.any? { |c| c[0] <= User::ALL_OF_ALL }
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
