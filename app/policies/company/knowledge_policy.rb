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
      user.admin?
    end

    def edit?
      update?
    end

    def export?
      update?
    end

    def update?
      user.admin? || user.knowledge_maintainer?
    end

    def destroy?
      user.admin? || user.email == 'chenzifan@thape.com.cn'
    end
  end
end
