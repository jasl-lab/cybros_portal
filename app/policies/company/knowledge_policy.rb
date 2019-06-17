module Company
  class KnowledgePolicy < ApplicationPolicy
    def index?
      true
    end

    def show?
      true
    end

    def modal?
      true
    end

    def new?
      create?
    end

    def create?
      user.admin? || user.email == 'chenzifan@thape.com.cn' || %(忻琳 聂玲玲 冯可 季建杰 柳怡帆).include?(user.chinese_name)
    end

    def edit?
      update?
    end

    def export?
      update?
    end

    def update?
      user.admin? || user.email == 'chenzifan@thape.com.cn' || %(忻琳 聂玲玲 冯可 季建杰 柳怡帆).include?(user.chinese_name)
    end

    def destroy?
      user.admin? || user.email == 'chenzifan@thape.com.cn'
    end
  end
end
