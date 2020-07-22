# frozen_string_literal: true

module Bi
  class ContractProductionDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS })
          scope.where(orgname: user.departments.pluck(:company_name))
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.admin?
    end

    def cp_drill_down?
      show? || user.user_company_names.include?(record.orgname)
    end
  end
end
