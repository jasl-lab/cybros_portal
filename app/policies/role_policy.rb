# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id).or(scope.where(email: user.email))
      end
    end
  end

  def index?
    user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员]) }
  end
end
