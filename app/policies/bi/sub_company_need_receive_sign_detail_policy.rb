# frozen_string_literal: true

module Bi
  class SubCompanyNeedReceiveSignDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS })
          can_access_org_codes = user.can_access_org_codes.append(user.user_company_orgcode)
          scope.where(orgcode: can_access_org_codes)
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.operation_access_codes.any? { |c| c[0] <= User::MY_COMPANY_EXCEPT_OTHER_DEPTS } || user.admin?
    end

    def hide?
      show?
    end

    def un_hide?
      hide?
    end
  end
end
