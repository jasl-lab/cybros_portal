# frozen_string_literal: true

module OperationEntry
  class CostStructureEntryPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin?)
    end
  end
end
