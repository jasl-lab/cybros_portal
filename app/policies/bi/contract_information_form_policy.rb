# frozen_string_literal: true

module Bi
  class ContractInformationFormPolicy < Struct.new(:user, :dashboard)
    def show?
      return scope.none unless user.present?

      user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员 CW_所级管理者1 CW_所级管理者2]) } ||
        user.admin?
    end
  end
end
