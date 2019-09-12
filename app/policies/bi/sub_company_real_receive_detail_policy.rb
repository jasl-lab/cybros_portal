# frozen_string_literal: true

module Bi
  class SubCompanyRealReceiveDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?)
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
