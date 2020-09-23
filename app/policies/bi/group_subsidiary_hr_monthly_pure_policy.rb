# frozen_string_literal: true

module Bi
  class GroupSubsidiaryHrMonthlyPurePolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员]) } ||
        user.admin?
    end
  end
end
