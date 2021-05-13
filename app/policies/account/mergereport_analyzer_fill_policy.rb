# frozen_string_literal: true

module Account
  class MergereportAnalyzerFillPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) } ||
          user.chinese_name.in?(%w(郭颖杰 陆文娟 毕赢 王艺)))
    end
  end
end
