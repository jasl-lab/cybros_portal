# frozen_string_literal: true

module Bi
  class NewMapInfoPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      user.admin?
    end

    def index?
      user.admin?
    end
  end
end
