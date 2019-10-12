# frozen_string_literal: true

module Bi
  class ShRefreshRatePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?) && \
           user.departments.pluck(:company_name).uniq == ["上海天华建筑设计有限公司"]
          scope.all
        else
          scope.where(orgcode: current_user.user_company_orgcode)
        end
      end
    end
  end
end
