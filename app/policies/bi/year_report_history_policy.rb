# frozen_string_literal: true

module Bi
  class YearReportHistoryPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def show?
      user.present? && user.admin?
    end
  end
end
