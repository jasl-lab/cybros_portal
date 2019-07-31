module Company
  class DirectQuestionPolicy < ApplicationPolicy
    def index?
      create?
    end

    def create?
      user.knowledge_maintainer?
    end

    def destroy?
      user.knowledge_maintainer?
    end
  end
end
