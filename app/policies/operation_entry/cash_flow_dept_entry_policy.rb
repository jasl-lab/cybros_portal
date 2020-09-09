# frozen_string_literal: true

module OperationEntry
  class CashFlowDeptEntryPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin?)
    end
  end
end
