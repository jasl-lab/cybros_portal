module Bi
  class CompleteValueDeptPolicy < BasePolicy
    def show?
      user&.report_maintainer?
    end
  end
end
