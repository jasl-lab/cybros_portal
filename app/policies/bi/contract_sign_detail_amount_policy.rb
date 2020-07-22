module Bi
  class ContractSignDetailAmountPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? \
          || user.roles.pluck(:report_company_detail_viewer).any? \
          || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS })
          allow_orgcodes = user.can_access_org_codes
          scope.where(orgcode: allow_orgcodes).or(scope.where(orgcode_sum: allow_orgcodes))
        else
          scope.none
        end
      end
    end

    def drill_down_amount?
      show? || (user.roles.pluck(:report_company_detail_viewer).any? && user.user_company_names.include?(record.orgname) && user.user_department_names.include?(record.deptname))
    end
  end
end
