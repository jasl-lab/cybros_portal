module Bi
  class SubCompanyRealReceivePolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_maintainer?
          scope.all
        else
          scope.where(businessltdname: user.departments.pluck(:company_name))
        end
      end
    end

    def show?
      true
    end
  end
end
