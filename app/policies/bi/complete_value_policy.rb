# frozen_string_literal: true

module Bi
  class CompleteValuePolicy < BasePolicy
    def show?
      user&.report_viewer? || user&.report_admin?
    end
  end
end
