# frozen_string_literal: true

module Bi
  class ContractHoldSignDetailPolicy < BasePolicy
    def show?
      user&.report_viewer? || user&.report_admin?
    end

    def export_sign_detail?
      user&.report_viewer? || user&.report_admin?
    end
  end
end
