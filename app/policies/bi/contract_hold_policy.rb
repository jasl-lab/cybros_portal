# frozen_string_literal: true

module Bi
  class ContractHoldPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_maintainer?
          scope.where(orgcode: "000101")
        else
          scope.none
        end
      end
    end

    def show?
      user&.report_maintainer?
    end
  end
end
