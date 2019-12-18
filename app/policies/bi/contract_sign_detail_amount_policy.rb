module Bi
  class ContractSignDetailAmountPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
          allow_orgcodes = user.departments.pluck(:company_name)
          scope.where(orgcode: allow_orgcodes).or(scope.where(orgcode_sum: allow_orgcodes))
        else
          scope.none
        end
      end
    end

    def drill_down_amount?
      show? || user.user_company_names.include?(record.orgname)
    end
  end
end
