# frozen_string_literal: true

module Cad
  class CadOperationPolicy < ApplicationPolicy
    def index?
      return false unless user.present?
      user.roles.pluck(:cad_session).any? || user.admin?
    end

    def report_operations?
      index?
    end
  end
end
