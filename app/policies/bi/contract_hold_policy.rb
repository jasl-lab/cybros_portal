# frozen_string_literal: true

module Bi
  class ContractHoldPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.where(orgcode: "000101")
      end
    end

    def show?
      user&.report_maintainer?
    end
  end
end
