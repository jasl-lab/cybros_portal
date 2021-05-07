# frozen_string_literal: true

module Bi
  class DeptHomepagePolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? || \
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员 CW_集团高管]) } || \
        (user.user_cw_access_orgcodes.include?('000101') && user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_子公司高管1 CW_子公司高管2 CW_所级管理者1 CW_所级管理者2]) })
    end
  end
end
