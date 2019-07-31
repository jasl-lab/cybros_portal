# frozen_string_literal: true

module Bi
  class TrackContractPolicy < BasePolicy
    class Scope < Scope
      def resolve
        if user&.report_maintainer?
          scope.where(BUSINESSLTDCODE: "000101")
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
