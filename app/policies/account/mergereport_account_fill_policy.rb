# frozen_string_literal: true

module Account
  class MergereportAccountFillPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员]) } 
        	|| user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_子公司财务经理]) } ||
        	user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务管理员]) } ||
          user.chinese_name.in?(%w(郭颖杰 陆文娟 毕赢 王艺 郑贤来 李玉鹏 王旭煜 曾思哲)))
    end
  end
end
