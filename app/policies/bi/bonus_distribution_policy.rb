# frozen_string_literal: true

module Bi
  class BonusDistributionPolicy < Struct.new(:user, :dashboard)
    def show?
      return scope.none unless user.present?

      user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛 陈一恺 高洋)) ||
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员 CW_所级管理者1]) } ||
        user.admin?
    end
  end
end
