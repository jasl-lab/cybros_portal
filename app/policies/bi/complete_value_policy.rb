# frozen_string_literal: true

module Bi
  class CompleteValuePolicy < BasePolicy
    def show?
      user&.report_maintainer?
    end
  end
end
