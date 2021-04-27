# frozen_string_literal: true

module IndexLibrary
  class IndexSummaryTablesPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? ||
        user.chinese_name.in?(%w[张晓辉 陈建 王星灿 叶馨 朱谊 陆文娟 周聪睿 郭颖杰 吴悠 袁士捷 毕赢 余慧 王旭冉])
    end
  end
end
