# frozen_string_literal: true

module Bi
  class DeptHomepagePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛 陈一恺)) ||
         user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_IT和人力管理员 HR_集团高管 HR_人力资源报表HR经理 HR_集团人力相关人员 HR_所级管理者 HR_子公司总经理、董事长]) }
         user.admin?)
    end
  end
end
