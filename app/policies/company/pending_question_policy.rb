module Company
  class PendingQuestionPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.roles.pluck(:knowledge_maintainer).any? || user.admin?
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
      user.present? && (user.roles.pluck(:knowledge_maintainer).any? || user.admin?)
    end

    def update?
      create?
    end

    def destroy?
      create?
    end
  end
end
