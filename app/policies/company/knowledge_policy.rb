# frozen_string_literal: true

module Company
  class KnowledgePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user&.in_tianhua_hq?
          scope.all
        else
          scope.where(shanghai_only: false)
        end
      end
    end

    def index?
      true
    end

    def show?
      true
    end

    def modal?
      true
    end

    def drill_down?
      user.present? && (user.roles.pluck(:knowledge_maintainer).any? || user.admin?)
    end

    def new?
      create?
    end

    def create?
      user.present? && (user.roles.pluck(:knowledge_maintainer).any? || user.admin?)
    end

    def edit?
      update?
    end

    def export?
      update?
    end

    def list?
      update?
    end

    def print_all?
      return false unless user.present?

      user.admin? || user.chinese_name.in?(%w[陈建 冯可])
    end

    def update?
      return false unless user.present?

      user.admin? || user.roles.pluck(:knowledge_maintainer).any?
    end

    def destroy?
      return false unless user.present?

      user.admin? || user.chinese_name.in?(%w[陈建 冯可])
    end
  end
end
