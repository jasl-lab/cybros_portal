# frozen_string_literal: true

module Bi
  class ContractProductionDeptPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?
        can_access_org_codes = user.can_access_org_codes
        if user.roles.pluck(:report_view_all).any? || user.admin? || can_access_org_codes == User::ALL_OF_ALL
          scope.all
        else
          scope.where(orgcode: can_access_org_codes).or(scope.where(orgcode_sum: can_access_org_codes))
        end
      end
    end
  end
end
