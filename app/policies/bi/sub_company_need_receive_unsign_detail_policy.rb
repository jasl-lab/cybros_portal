# frozen_string_literal: true

module Bi
  class SubCompanyNeedReceiveUnsignDetailPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_viewer? || user&.report_admin?
          scope.all
        else
          scope.where(orgname: user.departments.pluck(:company_name))
        end
      end
    end

    def hide?
      user&.report_viewer?
    end

    def un_hide?
      user&.report_viewer?
    end
  end
end
