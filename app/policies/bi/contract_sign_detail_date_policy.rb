# frozen_string_literal: true

module Bi
  class ContractSignDetailDatePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?) && \
           user.departments.pluck(:company_name).uniq == ["上海天华建筑设计有限公司"]
          scope.all
        else
          scope.where(orgname: user.departments.pluck(:company_name))
        end
      end
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
