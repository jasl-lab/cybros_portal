# frozen_string_literal: true

module Bi
  class ContractHoldUnsignDetailPolicy < BasePolicy
    def show?
      user&.report_viewer? || user&.report_admin?
    end

    def export_unsign_detail?
      user&.report_viewer? || user&.report_admin?
    end
  end
end
