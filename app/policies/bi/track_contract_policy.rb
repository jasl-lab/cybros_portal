# frozen_string_literal: true

module Bi
  class TrackContractPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.where(BUSINESSLTDCODE: "000101")
      end
    end
  end
end
