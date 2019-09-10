# frozen_string_literal: true

module Bi
  class SubCompanyNeedReceiveSignDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?)
          scope.all
        else
          scope.where(orgname: user.departments.pluck(:company_name))
        end
      end
    end

    def hide?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?
    end

    def un_hide?
      hide?
    end
  end
end
