# frozen_string_literal: true

module Account
  class OrgYearFillPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
<<<<<<< HEAD
        (user.admin? ||
         user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员 CW_子公司高管1 CW_子公司高管2 CW_填报人]) } ||
         user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛 陈一恺)))
=======
        (user.admin? || user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_财务分析部管理员 CW_填报人]) } || 
        	user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛 陈一恺)))
>>>>>>> df2e057f... change account fill report policy
    end
  end
end
