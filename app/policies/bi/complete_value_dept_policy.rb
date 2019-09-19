# frozen_string_literal: true

module Bi
  class CompleteValueDeptPolicy < BasePolicy
    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?
    end
  end
end
