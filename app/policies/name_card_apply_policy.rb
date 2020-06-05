class NameCardApplyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def report?
    user.admin? || user.chinese_name == '丁一'
  end
end
