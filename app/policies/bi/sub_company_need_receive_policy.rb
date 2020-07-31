module Bi
  class SubCompanyNeedReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? \
          || user.admin?)
          scope.all
        elsif user.present? && (user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_ALL_DETAILS })
          allow_orgcodes = user.can_access_org_codes
          scope.where(orgcode: allow_orgcodes).or(scope.where(orgcode_sum: allow_orgcodes))
        elsif user.present? && (user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS })
          allow_orgcodes = user.can_access_org_codes
          scope.where(orgcode: allow_orgcodes, deptcode: can_access_dept_codes).or(scope.where(orgcode_sum: allow_orgcodes, deptcode_sum: can_access_dept_codes))
        else
          scope.none
        end
      end

      def group_resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? \
          || user.roles.pluck(:report_view_all).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::ALL_EXCEPT_OTHER_COMPANY_DETAILS } \
          || user.admin?)
          scope.all
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
