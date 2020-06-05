class NameCardApplyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.chinese_name == '吴婷'
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def report?
    user.admin? || user.chinese_name == '吴婷'
  end
end
