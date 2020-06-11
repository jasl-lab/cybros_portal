# frozen_string_literal: true

module Bi
  class ContractSignDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?
        can_access_org_codes = user.can_access_org_codes.append(user.user_company_orgcode)
        if user.roles.pluck(:report_view_all).any? || user.admin? || can_access_org_codes == User::ALL_OF_ALL
          scope.all
        elsif user.roles.pluck(:report_viewer).any? \
          || user.roles.pluck(:report_company_detail_viewer).any? \
          || user.job_level.to_i >= 11
          scope.where(orgcode: can_access_org_codes).or(scope.where(orgcode_sum: can_access_org_codes))
        else
          scope.none
        end
      end
    end
  end
end
