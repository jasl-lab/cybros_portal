# frozen_string_literal: true

class NameCardApplyPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[管理名片]) }
        scope.all
      else
        scope.where(user_id: user.id).or(scope.where(email: user.email))
      end
    end
  end

  def report?
    user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[管理名片]) }
  end

  def upload?
    user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[管理名片]) }
  end
end
