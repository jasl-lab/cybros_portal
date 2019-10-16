# frozen_string_literal: true

module Bi
  class ContractProductionDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? &&
           (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?) &&
           (user.departments.pluck(:company_name).uniq == ["上海天华建筑设计有限公司"])
          scope.all
        else
          allow_orgcodes = user.departments.pluck(:company_name)
            .collect { |n| Bi::OrgShortName.org_code_by_long_name.fetch(n, n) }
          scope.where(orgcode: allow_orgcodes)
        end
      end
    end
  end
end
