module Company
  class PendingQuestionPolicy < ApplicationPolicy
    def index?
      true
    end

    def create?
      user.admin? || user.knowledge_maintainer?
    end

    def destroy?
      user.admin? || user.email == 'chenzifan@thape.com.cn'
    end
  end
end
