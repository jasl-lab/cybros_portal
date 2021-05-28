# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员]) }
        scope.where('role_name LIKE "HR_%"')
      end
    end
  end

  def index?
    user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员]) }
  end
end
