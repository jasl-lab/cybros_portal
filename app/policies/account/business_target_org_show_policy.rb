# frozen_string_literal: true

module Account
  class BusinessTargetOrgShowPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || \
          user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) } || \
          user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 聂琳 冯巧容 朱谊 王旭冉 王俐雯)))
    end
  end
end
