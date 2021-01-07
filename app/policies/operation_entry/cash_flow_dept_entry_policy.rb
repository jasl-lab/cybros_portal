# frozen_string_literal: true

module OperationEntry
  class CashFlowDeptEntryPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin? || user.chinese_name.in?(%w(周聪睿 余慧 吴悠)))
    end
  end
end
