module Company
  class DirectQuestionPolicy < ApplicationPolicy
    def index?
      create?
    end

    def create?
      user.present? && (user.roles.pluck(:knowledge_maintainer).any? || user.admin?)
    end

    def destroy?
      create?
    end
  end
end
