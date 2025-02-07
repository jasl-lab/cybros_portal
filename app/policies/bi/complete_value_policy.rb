# frozen_string_literal: true

module Bi
  class CompleteValuePolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? \
          || user.roles.pluck(:report_view_all).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS }
          scope.all
        elsif user.roles.pluck(:report_viewer).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_ALL_DETAILS }
          scope.where(orgcode: user.can_access_org_codes)
        elsif user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS }
          scope.where(orgcode: user.can_access_org_codes, deptcode: user.can_access_dept_codes)
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.admin? \
        || user.roles.pluck(:report_viewer).any? \
        || user.roles.pluck(:report_view_all).any? \
        || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS }
    end
  end
end
