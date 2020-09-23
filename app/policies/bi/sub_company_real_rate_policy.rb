# frozen_string_literal: true

module Bi
  class SubCompanyRealRatePolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.roles.pluck(:report_view_all).any? || user.admin?
          scope.all
        elsif user.roles.pluck(:report_viewer).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_ALL_DETAILS }
          allow_orgcodes = user.can_access_org_codes
          scope.where(orgcode: allow_orgcodes).or(scope.where(orgcode_sum: allow_orgcodes))
        elsif user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS }
          allow_orgcodes = user.can_access_org_codes
          scope.where(orgcode: allow_orgcodes, deptcode: user.can_access_dept_codes).or(scope.where(orgcode_sum: allow_orgcodes, deptcode_sum: user.can_access_dept_codes))
        else
          scope.none
        end
      end
    end
  end
end
