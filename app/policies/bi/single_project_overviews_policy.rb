# frozen_string_literal: true

module Bi
  class SingleProjectOverviewsPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && ( user.chinese_name.in?(%w(郭颖杰 余慧 陆文娟 周聪睿 蒋磊 吴悠 毕赢 孙涛)) || user.admin? )
    end
  end
end
