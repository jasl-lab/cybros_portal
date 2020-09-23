# frozen_string_literal: true

module Bi
  class ContractSignDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        can_access_org_codes = user.can_access_org_codes.append(user.user_company_orgcode)
        can_access_dept_codes = user.can_access_dept_codes
        if user.roles.pluck(:report_view_all).any? || user.admin?
          scope.all
        elsif user.roles.pluck(:report_viewer).any? \
          || user.roles.pluck(:report_company_detail_viewer).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_ALL_DETAILS }
          scope.where(orgcode: can_access_org_codes).or(scope.where(orgcode_sum: can_access_org_codes))
        elsif user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS }
          scope.where(orgcode: can_access_org_codes, deptcode: can_access_dept_codes).or(scope.where(orgcode_sum: can_access_org_codes, deptcode_sum: can_access_dept_codes))
        else
          scope.none
        end
      end

      def group_resolve
        return scope.none unless user.present?

        allow_orgcodes = user.can_access_org_codes
        if allow_orgcodes.include?('000109') && # 武汉天华
          user.operation_access_codes.any? { |c| c[0] == User::MY_COMPANY_ALL_DETAILS }
          scope.where(orgcode: allow_orgcodes).or(scope.where(orgcode_sum: allow_orgcodes))
        elsif allow_orgcodes.include?('000109') && # 武汉天华
          user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS }
          can_access_dept_codes = user.can_access_dept_codes
          scope.where(orgcode: allow_orgcodes, deptcode: can_access_dept_codes).or(scope.where(orgcode_sum: allow_orgcodes, deptcode_sum: can_access_dept_codes))
        elsif user.roles.pluck(:report_view_all).any? || user.admin?
          scope.all
        elsif user.roles.pluck(:report_viewer).any? \
          || user.roles.pluck(:report_company_detail_viewer).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS }
          can_access_org_codes = user.can_access_org_codes.append(user.user_company_orgcode)
          scope.where(orgcode: can_access_org_codes).or(scope.where(orgcode_sum: can_access_org_codes))
        else
          scope.none
        end
      end
    end
  end
end
