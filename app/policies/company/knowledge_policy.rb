module Company
  class KnowledgePolicy < ApplicationPolicy
    def index?
      true
    end

    def modal?
      true
    end

    def new?
      create?
    end

    def create?
      user.admin? || user.email == 'chenzifan@thape.com.cn'
    end

    def edit?
      update?
    end

    def update?
      user.admin? || user.email == 'chenzifan@thape.com.cn'
    end

    def destroy?
      user.admin? || user.email == 'chenzifan@thape.com.cn'
    end
  end
end
