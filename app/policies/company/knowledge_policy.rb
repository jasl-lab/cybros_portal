module Company
  class KnowledgePolicy < ApplicationPolicy
    def index?
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

    def update?
      user.admin?
    end
  end
end
