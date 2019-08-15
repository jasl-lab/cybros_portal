# frozen_string_literal: true

module Bi
  class ContractHoldUnsignDetailPolicy < BasePolicy
    def show?
      user&.report_maintainer?
    end

    def export_unsign_detail?
      user&.report_maintainer?
    end
  end
end
