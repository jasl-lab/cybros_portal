# frozen_string_literal: true

module Bi
  class BasePolicy < ApplicationPolicy
    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? \
      || user.roles.pluck(:report_view_all).any? \
      || user.job_level.to_i >= 11 || user.admin?
    end

    def export?
      show?
    end
  end
end
