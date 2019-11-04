# frozen_string_literal: true

module Bi
  class ContractSignDetailDatePolicy < BasePolicy
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
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.job_level.to_i >= 11 || user.admin?
    end

    def drill_down_date?
      show? || user.user_company_names.include?(record.orgname)
    end

    def hide?
      show?
    end

    def un_hide?
      show?
    end
  end
end
