module Company
  class PendingQuestionPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.admin? || user.knowledge_maintainer?
          scope.all
        else
          scope.where(owner_id: user.id)
        end
      end
    end

    def index?
      create?
    end

    def create?
      user.admin? || user.knowledge_maintainer?
    end

    def update?
      user.admin? || user.knowledge_maintainer?
    end

    def destroy?
      user.admin? || user.knowledge_maintainer?
    end
  end
end
