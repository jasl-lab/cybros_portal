# frozen_string_literal: true

module Bi
  class ContractProductionDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
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
