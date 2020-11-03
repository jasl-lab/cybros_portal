# frozen_string_literal: true

module Account
  class OperationSummaryOrgPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员 CW_集团高管 CW_子公司高管1]) } || 
        	user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛 陈一恺 陈玲)))
    end
  end
end
