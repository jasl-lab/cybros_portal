# frozen_string_literal: true

module Bi
  class ContractHoldPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
end
