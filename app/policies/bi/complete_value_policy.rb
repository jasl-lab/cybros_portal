# frozen_string_literal: true

module Bi
  class CompleteValuePolicy < BasePolicy
    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.job_level.to_i >= 11 || user.admin?
    end
  end
end
