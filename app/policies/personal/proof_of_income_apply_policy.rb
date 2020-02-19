# frozen_string_literal: true

module Personal
  class ProofOfIncomeApplyPolicy < ApplicationPolicy
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
      user.chinese_name.in? %w(过纯中 赵峥逸 李俭 余慧 陈建)
    end
  end
end
