# frozen_string_literal: true

module Bi
  class ContractsGeographicalAnalysisPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && (user.roles.pluck(:report_view_all).any? || user.admin?)
    end
  end
end
