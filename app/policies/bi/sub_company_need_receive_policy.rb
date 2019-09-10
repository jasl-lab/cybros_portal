module Bi
  class SubCompanyNeedReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?)
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_reviewer).any? || user.admin?
    end
  end
end
