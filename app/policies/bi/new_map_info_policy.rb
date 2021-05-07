# frozen_string_literal: true

module Bi
  class NewMapInfoPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || \
            user.positions.any? do |position|
              return false unless position.baseline_position_access.present?

              position.baseline_position_access.contract_map_access.in?(%w[project_detail_with_download view_project_details])
            end || \
            user.roles.pluck(:project_map_viewer).any?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?

      user.admin? || \
        user.positions.any? do |position|
          return false unless position.baseline_position_access.present?

          position.baseline_position_access.contract_map_access.in?(%w[project_detail_with_download view_project_details])
        end || \
        user.roles.pluck(:project_map_viewer).any?
    end

    def index?
      return false unless user.present?

      user.admin? || \
        user.positions.any? do |position|
          return false unless position.baseline_position_access.present?

          position.baseline_position_access.contract_map_access.in?(%w[project_detail_with_download view_project_details])
        end || \
        user.roles.pluck(:project_map_viewer).any?
    end

    def allow_download?
      return false unless user.present?

      user.admin? || \
        user.positions.any? do |position|
          return false unless position.baseline_position_access.present?

          position.baseline_position_access.contract_map_access.in?(%w[project_detail_with_download])
        end || \
        user.roles.pluck(:project_map_contract_download).any?
    end
  end
end
