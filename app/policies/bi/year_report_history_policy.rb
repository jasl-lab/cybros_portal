# frozen_string_literal: true

module Bi
  class YearReportHistoryPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def show?
      return false unless user.present?

      user.admin? \
        || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
        || user.roles.pluck(:group_report_viewer).any?
    end
  end
end
