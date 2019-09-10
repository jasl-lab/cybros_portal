# frozen_string_literal: true

module Bi
  class ContractHoldPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?
    end
  end
end
