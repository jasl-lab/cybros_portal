module Bi
  class BasePolicy < ApplicationPolicy
    def show?
      %(冯巧容 王玥 崔立杰 亢梦婕 付焕鹏 曾嵘 过纯中 许瑞庭).include?(user.chinese_name) && \
        user.departments.pluck(:company_name).uniq == ['上海天华建筑设计有限公司']
    end

    def export?
      show?
    end
  end
end
