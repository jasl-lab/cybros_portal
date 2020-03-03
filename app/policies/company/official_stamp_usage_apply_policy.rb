# frozen_string_literal: true

module Company
  class OfficialStampUsageApplyPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        else
          scope.where(user_id: user.id)
        end
      end
    end

    def index?
      user.chinese_name.in? %w(过纯中 赵峥逸 李俭 余慧 陈建 高於 周芳 龙墨涵 任炜炜 徐雅蓉)
    end
  end
end
