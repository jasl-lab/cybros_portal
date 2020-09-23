# frozen_string_literal: true

module Bi
  class SubCompanyRealReceiveDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.admin?
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
