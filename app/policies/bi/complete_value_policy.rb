# frozen_string_literal: true

module Bi
  class CompleteValuePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.admin? || %w[000176].include?(user.clerk_code))
          scope.all
        elsif user.present? && (user.roles.pluck(:report_viewer).any? || user.job_level.to_i >= 11)
          scope.where(orgcode: user.user_company_orgcode)
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.admin? || %w[000176].include?(user.clerk_code) \
        || user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.job_level.to_i >= 11
    end
  end
end
