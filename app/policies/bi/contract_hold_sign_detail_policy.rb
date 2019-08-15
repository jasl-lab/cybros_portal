# frozen_string_literal: true

module Bi
  class ContractHoldSignDetailPolicy < BasePolicy
    def show?
      user&.report_maintainer?
    end

    def export_sign_detail?
      user&.report_maintainer?
    end
  end
end
