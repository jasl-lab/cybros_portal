# frozen_string_literal: true

module SplitCost
  class MonthlySalarySplitRulePolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || user.chinese_name.in?(%w[高尧 方子雪 黄飞 王旭煜 郑贤来])
          scope.all
        else
          scope.none
        end
      end
    end

    def index?
      return false unless user.present?

      user.admin? || user.chinese_name.in?(%w[高尧 方子雪 黄飞 王旭煜 郑贤来])
    end
  end
end
