# frozen_string_literal: true

module Bi
  class TrackContractSigningDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_ALL_DETAILS })
          scope.where(orgcode: user.can_access_org_codes).or(scope.where(orgcode_sum: user.can_access_org_codes))
        elsif user.present? && (user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS })
          scope.where(orgcode: user.can_access_org_codes, deptcode: user.can_access_dept_codes).or(scope.where(orgcode_sum: user.can_access_org_codes, deptcode_sum: user.can_access_dept_codes))
        else
          scope.none
        end
      end
    end
  end
end
