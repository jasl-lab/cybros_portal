# frozen_string_literal: true

module Bi
  class SubCompanyRealReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
          allow_orgcodes = user.can_access_org_codes
          scope.where(orgcode: allow_orgcodes).or(scope.where(orgcode_sum: allow_orgcodes))
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? \
      || user.roles.pluck(:report_view_all).any? \
      || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
      || user.admin?
    end
  end
end
