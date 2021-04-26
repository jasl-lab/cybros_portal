# frozen_string_literal: true

module Company
  class SmsPhoneMappingPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.admin? || user.chinese_name.in?(%w[陈建])
          scope.all
        else
          scope.where(user_id: user.id)
        end
      end
    end

    def index?
      return false unless user.present?

      user.admin? || user.chinese_name.in?(%w[陈建])
    end

    def edit?
      update?
    end

    def update?
      return false unless user.present?

      user.admin? || user.chinese_name.in?(%w[陈建])
    end
  end
end
