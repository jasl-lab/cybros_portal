# frozen_string_literal: true

module CostSplit
  class HomePolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? || user.chinese_name.in?(%w[高尧 方子雪 黄飞 王旭煜 郑贤来])
    end
  end
end
