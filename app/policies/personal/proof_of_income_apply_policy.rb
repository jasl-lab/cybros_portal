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

    def new?
      user.chinese_name.in? %w(过纯中 赵峥逸 李捡)
    end
  end
end
