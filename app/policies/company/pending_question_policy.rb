module Company
  class PendingQuestionPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.knowledge_maintainer?
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
      user.knowledge_maintainer?
    end

    def update?
      user.knowledge_maintainer?
    end

    def destroy?
      user.knowledge_maintainer?
    end
  end
end
