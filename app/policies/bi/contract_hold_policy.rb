# frozen_string_literal: true

module Bi
  class ContractHoldPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?) && \
           user.departments.pluck(:company_name).uniq == ["上海天华建筑设计有限公司"]
          scope.all
        elsif user.present?
          scope.where(orgcode: user.user_company_orgcode)
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?
    end
  end
end
