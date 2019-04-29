class NameCardApplyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user_id)
      end
    end
  end
end
