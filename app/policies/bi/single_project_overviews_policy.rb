# frozen_string_literal: true

module Bi
  class SingleProjectOverviewsPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? || \
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) } || \
        (user.user_company_orgcodes.include?('000101') && user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_所级管理者1 CW_所级管理者2]) })
    end
  end
end
