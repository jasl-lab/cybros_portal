# frozen_string_literal: true

module Bi
  class BasePolicy < ApplicationPolicy
    def show?
      return false unless user.present?
      (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?) &&
        user.departments.pluck(:company_name).uniq == ["上海天华建筑设计有限公司"]
    end

    def export?
      show?
    end
  end
end
