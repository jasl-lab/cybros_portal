# frozen_string_literal: true

module Bi
  class OrgMarketFeesPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.chinese_name.in?(%w[章静 聂琳]) ||
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) } ||
        user.admin?
    end
  end
end
