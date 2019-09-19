# frozen_string_literal: true

module Bi
  class CompleteValueDetailPolicy < BasePolicy
    def drill_down?
      show?
    end
  end
end
