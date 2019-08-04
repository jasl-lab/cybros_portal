# frozen_string_literal: true

module Bi
  class ContractHoldUnsignDetailPolicy < BasePolicy
    def show?
      user&.report_maintainer?
    end
  end
end
