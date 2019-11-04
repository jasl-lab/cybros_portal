module Bi
  class SubCompanyNeedReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user.present? && (user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? || user.job_level.to_i >= 11 || user.admin?)
          scope.all
        else
          scope.none
        end
      end
    end

    def show?
      return false unless user.present?
      user.roles.pluck(:report_viewer).any? || user.roles.pluck(:report_view_all).any? \
      || user.job_level.to_i >= 11 || user.admin?
    end
  end
end
