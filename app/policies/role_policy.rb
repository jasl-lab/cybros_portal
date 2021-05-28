# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员]) }
        scope.where('role_name LIKE "HR_%"')
      elsif user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) }
        scope.where('role_name LIKE "CW_%"')
      end
    end
  end

  def index?
    user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员 CW_财务分析部管理员]) }
  end

  def show?
    if user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员]) }
      return record.role_name.start_with? 'HR_'
    elsif user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) }
      return record.role_name.start_with? 'CW_'
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
