# frozen_string_literal: true

module Bi
  class GroupHrMonthlyPurePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.admin? || user.roles.any? { |r| r.role_name == '人力资源报表管理员' })
    end
  end
end
