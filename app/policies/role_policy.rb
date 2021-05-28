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

  def show?
    if user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员]) }
      return record.role_name.start_with? 'HR_'
    end

    user.admin?
  end

  def update?
    show?
  end

  def user?
    show?
  end
end
