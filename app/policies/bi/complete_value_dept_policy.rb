module Bi
  class CompleteValueDeptPolicy < BasePolicy
    def show?
      user&.report_viewer? || user&.report_admin?
    end
  end
end
