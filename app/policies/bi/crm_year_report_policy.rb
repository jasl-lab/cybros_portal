# frozen_string_literal: true

module Bi
  class CrmYearReportPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin?
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?

      user.admin? || user.chinese_name.in?(%w[王俐雯 王旭冉])
    end
  end
end
