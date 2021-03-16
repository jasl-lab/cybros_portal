# frozen_string_literal: true

module Bi
  class NewMapInfoPolicy < BasePolicy
    ALLOW_SHOW_TITLES = %w[商务经理 管理副所长 所长助理 所长 市场总监 总经理助理 副总经理 总经理 运营分析经理].freeze
    ALLOW_DOWNLOAD_HQ_TITLES = %w[管理副所长 所长助理 所长 市场总监 总经理助理 副总经理 总经理 运营分析经理].freeze
    ALLOW_DOWNLOAD_SUBSIDIARY_TITLES = %w[总经理助理 副总经理 总经理].freeze

    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || \
           ALLOW_SHOW_TITLES.any? { |title| user.position_title.include?(title) } || \
           user.roles.pluck(:project_map_viewer).any?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      user.present? && (user.admin? || ALLOW_SHOW_TITLES.any? { |title| user.position_title.include?(title) } || user.roles.pluck(:project_map_viewer).any?)
    end

    def index?
      user.present? && (user.admin? || ALLOW_SHOW_TITLES.any? { |title| user.position_title.include?(title) } || user.roles.pluck(:project_map_viewer).any?)
    end

    def allow_download?
      user.admin? || (user.in_tianhua_hq? && ALLOW_DOWNLOAD_HQ_TITLES.any? { |title| user.position_title.include?(title) }) \
        || (!user.in_tianhua_hq? && ALLOW_DOWNLOAD_SUBSIDIARY_TITLES.any? { |title| user.position_title.include?(title) }) \
        || user.roles.pluck(:project_map_contract_download).any?
    end
  end
end
