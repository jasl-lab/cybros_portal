# frozen_string_literal: true

module Account
  class InteriorFillPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛 陈一恺 陈玲)) ||
        	( user.roles.pluck(:role_name).any? { |r| r.in?(%w[CW_子公司高管1 CW_子公司高管2 CW_填报人]) } \
        		&& user.user_company_orgcodes.include?(%w[000113 000152 000153]))
        )
    end
  end
end

