# frozen_string_literal: true

module Bi
  class NewMapInfoPolicy < BasePolicy
    ALLOW_SHOW_TITLES = %w[商务经理 管理副所长 所长助理 所长 所长（结构）市场总监 总经理助理 副总经理 副总经理F 总经理 运营分析经理].freeze
    ALLOW_DOWNLOAD_HQ_TITLES = %w[管理副所长 所长助理 所长 所长（结构）市场总监 总经理助理 副总经理 副总经理F 总经理 运营分析经理].freeze
    ALLOW_DOWNLOAD_SUBSIDIARY_TITLES = %w[总经理助理 副总经理 总经理].freeze

    class Scope < Scope
      def resolve
        if user.admin? || user.position_title.in?(ALLOW_SHOW_TITLES) || user.roles.pluck(:project_map_viewer).any?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      user.admin? || user.position_title.in?(ALLOW_SHOW_TITLES) || user.roles.pluck(:project_map_viewer).any?
    end

    def index?
      user.admin? || user.position_title.in?(ALLOW_SHOW_TITLES) || user.roles.pluck(:project_map_viewer).any?
    end

    def allow_download?
      user.admin? || (user.in_tianhua_hq? && user.position_title.in?(ALLOW_DOWNLOAD_HQ_TITLES)) \
        || (!user.in_tianhua_hq? && user.position_title.in?(ALLOW_DOWNLOAD_SUBSIDIARY_TITLES)) \
        || user.roles.pluck(:project_map_viewer).any?
    end
  end
end
