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
      true
    end

    def new?
      create?
    end

    def create?
      user.roles.pluck(:knowledge_maintainer).any? || user.admin?
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

    def update?
      user.roles.pluck(:knowledge_maintainer).any? || user.admin?
    end

    def destroy?
      user.admin?
    end
  end
end
