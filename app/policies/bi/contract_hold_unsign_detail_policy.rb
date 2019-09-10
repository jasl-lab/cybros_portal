# frozen_string_literal: true

module Bi
  class ContractHoldUnsignDetailPolicy < BasePolicy
    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?
    end

    def export_unsign_detail?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?
    end
  end
end
