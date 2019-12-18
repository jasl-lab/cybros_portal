# frozen_string_literal: true

module Bi
  class ContractProductionDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
          allow_orgcodes = user.departments.pluck(:company_name)
            .collect { |n| Bi::OrgShortName.org_code_by_long_name.fetch(n, n) }
          scope.where(orgcode: allow_orgcodes).or(scope.where(orgcode_sum: allow_orgcodes))
        else
          scope.none
        end
      end
    end
  end
end
