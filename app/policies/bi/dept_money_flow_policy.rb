# frozen_string_literal: true

module Bi
  class DeptMoneyFlowPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.roles.pluck(:report_view_all).any? || user.admin? \
          || user.operation_access_codes.any? { |c| c[0] <= User::ALL_OF_ALL }
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?

      user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛 陈一恺 陈玲)) ||
        user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) } ||
        user.admin?
    end
  end
end
